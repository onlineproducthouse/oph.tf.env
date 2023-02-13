#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/ci/container/ecr/terraform.tfstate"
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

variable "region" {}
variable "owner" {}
variable "environment_name" {}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "database" {
  source = "../../../../../../../module/interface/aws/containers/ecr"

  name         = "dph/database"
  service_name = "database"

  owner            = var.owner
  environment_name = var.environment_name
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "registry" {
  value = {
    database = module.database.name
  }
}
