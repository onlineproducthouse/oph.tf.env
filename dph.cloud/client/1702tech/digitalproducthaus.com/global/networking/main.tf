#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/networking/terraform.tfstate"
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
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "domain_name" {
  type    = string
  default = ""
}

variable "email_mx" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "dns" {
  source = "../../../../../module/implementation/network/dns"

  region           = var.region
  owner            = var.owner
  environment_name = var.environment_name
  domain_name      = var.domain_name
  domain_email_mx  = var.email_mx
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "hosted_zone_id" {
  value = module.dns.hosted_zone_id
}

output "domain_name_servers" {
  value = module.dns.domain_name_servers
}

output "domain_name" {
  value = module.dns.domain_name
}
