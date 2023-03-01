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
