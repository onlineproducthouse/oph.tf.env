#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-database/ci/terraform.tfstate"
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
  region = var.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################


variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "ci" {
  source = "../../../../../../module/implementation/service/ci"

  owner            = var.owner
  environment_name = var.environment_name

  config_switch = {
    build          = false
    build_artefact = false
    deploy         = false
    registry       = true
  }

  registry = {
    name         = "dph/database"
    service_name = "database"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ci" {
  value = module.ci
}
