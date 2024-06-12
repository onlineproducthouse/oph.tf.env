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
      version = "4.60.0"
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

variable "vpc_in_use" {
  type    = bool
  default = false
}

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
  shared_resource_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}"

  availibility_zones = ["eu-west-1a"]

  cidr_blocks = {
    vpc    = "10.0.0.0/16"
    public = "0.0.0.0/0"

    subnets = {
      private = ["10.0.50.0/24"]
      public  = ["10.0.0.0/24"]
    }
  }
}

locals {
  api = {
    name = local.shared_resource_name
    port = 80

    compute = {
      instance = {
        image_id      = "ami-0ef8272297113026d"
        instance_type = "t3a.micro"
      }

      auto_scaling = {
        minimum = 1
        maximum = 1
        desired = 1
      }
    }

    container = {
      launch_type               = "EC2"
      enable_container_insights = false
      network_mode              = "host"
      log_group                 = local.shared_resource_name

      cpu    = 1400
      memory = 650

      desired_tasks_count                = 1
      target_capacity                    = 100
      deployment_minimum_healthy_percent = 100
      deployment_maximum_healthy_percent = 200
    }

    load_balancer = {
      domain_name_prefix = var.client_info.project_short_name
      health_check_path  = "/" # /api/v1/HealthCheck/Ping OR /index.html
      hosted_zone = {
        id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      }
      listener = {
        certificate = {
          arn         = data.terraform_remote_state.acm_certs.outputs.test.api.cert_arn
          domain_name = data.terraform_remote_state.acm_certs.outputs.test.api.cert_domain_name
        }
      }
    }

    network = {
      in_use             = var.vpc_in_use
      availibility_zones = local.availibility_zones
      cidr_blocks = {
        vpc    = local.cidr_blocks.vpc
        public = local.cidr_blocks.public

        subnets = {
          private = local.cidr_blocks.subnets.private
          public  = local.cidr_blocks.subnets.public
        }
      }
    }
  }

  web = [{
    name = "www"

    host = {
      vpc_in_use = var.vpc_in_use
      error_page = "index.html"
      index_page = "index.html"
    }

    cdn = {
      hosted_zone_id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      certificate = {
        arn         = data.terraform_remote_state.acm_certs.outputs.test.web.cert_arn
        domain_name = "www.${data.terraform_remote_state.acm_certs.outputs.test.web.cert_domain_name}"
      }
    }
  }]
}

module "test" {
  source = "../../../../../../module/implementation/service/env"

  client_info = var.client_info

  content = {
    db_cert_source_path = "./content/root.crt"
  }

  api = local.api
  web = local.web
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "content" {
  value = module.test.content
}

output "api" {
  value = module.test.api
}

output "web" {
  value = module.test.web
}
