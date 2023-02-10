#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/security/iam/group/terraform.tfstate"
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

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "developer_policies" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/security/iam/policy/developer/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "operations_policies" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/security/iam/policy/operations/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "developer_group" {
  source = "../../../../module/interface/aws/security/iam/group"

  group_name                       = "developer"
  iam_group_attach_policy_arn_list = local.policies.developer_policies
}

module "operations_group" {
  source = "../../../../module/interface/aws/security/iam/group"

  group_name                       = "operations"
  iam_group_attach_policy_arn_list = local.policies.operations_policies
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "developer_group" {
  value = module.developer_group.name
}

output "operations_group" {
  value = module.operations_group.name
}
