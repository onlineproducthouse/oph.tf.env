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
  region = var.client_info.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
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
  source = "../../../../../module/implementation/shared/network/dns"

  client_info     = var.client_info
  domain_name     = var.domain_name
  domain_email_mx = var.email_mx
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "dns" {
  value = {
    domain_name    = module.dns.domain_name
    hosted_zone_id = module.dns.hosted_zone_id
    name_servers   = module.dns.domain_name_servers
  }
}
