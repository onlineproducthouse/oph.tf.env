#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/local/service/database/dph/config/runtime/terraform.tfstate"
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
  type = string
}

variable "owner" {
  type = string
}

variable "environment_name" {
  type = string
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

locals {
  path = "/dph/runtime/local"
}

module "environment_variables" {
  source = "../../../../../../../../../module/interface/aws/security/ssm/param_store"

  region = var.region

  owner            = var.owner
  environment_name = var.environment_name

  parameters = [
    { path : local.path, key : "DB_PROTOCOL", value : "postgres" },
    { path : local.path, key : "DB_USERNAME", value : "root" },
    { path : local.path, key : "DB_PASSWORD", value : "password" },
    { path : local.path, key : "DB_HOST", value : "127.0.0.1" },
    { path : local.path, key : "DB_PORT", value : "5432" },
    { path : local.path, key : "DB_NAME", value : "LocalDB" },
    { path : local.path, key : "IMAGE_REGISTRY_BASE_URL", value : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.region}.amazonaws.com" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "path" {
  value = local.path
}
