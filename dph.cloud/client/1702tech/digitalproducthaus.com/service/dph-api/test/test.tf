#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-api/test/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                      VERSIONS                     #
#                                                   #
#####################################################

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      version = "4.8.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.client_info.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "acm_certs" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/ssl/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  vpc_cidr_block     = "" // leave empty to disable else set to, e.g. 10.0.0.0/16
  availibility_zones = ["eu-west-1b", "eu-west-1c"]
}

locals {
  content = {
    db_cert_source_path = "./content/db-cert-test.crt"
  }

  env = {
    network = {
      vpc_cidr_block  = local.vpc_cidr_block
      dest_cidr_block = "0.0.0.0/0"

      subnets = {
        private = {
          availibility_zones = local.availibility_zones
          cidr_block         = ["10.0.50.0/24", "10.0.51.0/24"]
        }

        public = {
          availibility_zones = local.availibility_zones
          cidr_block         = ["10.0.0.0/24", "10.0.1.0/24"]
        }
      }
    }
  }
}

module "test" {
  source = "../../../../../../module/implementation/service/env"

  client_info = var.client_info
  env         = local.env
  content     = local.content

  compute = {
    auto_scaling_group = {
      desired_instances = 1
      max_instances     = 1
      min_instances     = 1
    }
    launch_configuration = {
      image_id      = "ami-027078d981e5d4010"
      instance_type = "t3a.micro"
    }
  }

  networking = {
    domain_name_prefix = "${var.client_info.project_short_name}api"
    hosted_zone = {
      id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
    }
    load_balancer = {
      listener = {
        certificate = {
          arn         = data.terraform_remote_state.acm_certs.outputs.test.cert_arn
          domain_name = data.terraform_remote_state.acm_certs.outputs.test.cert_domain_name
        }
      }
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "network" {
  value = module.test.network
}

output "content" {
  value = module.test.content
}

output "api" {
  value = module.test.api
}
