#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/email/terraform.tfstate"
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

variable "sg_sender_auth" {
  description = "Configuration for authenticating email address used in SendGrid"

  type = list(object({
    type  = string
    host  = string
    value = string
  }))

  default = []
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "sender_auth" {
  source = "../../../../../module/interface/aws/networking/route53/hosted_zone/dns_record"

  for_each = {
    for index, record in var.sg_sender_auth : record.host => record
  }

  zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  name    = each.value.host
  type    = each.value.type

  ttl     = "60"
  records = [each.value.value]

  with_alias             = false
  alias_zone_id          = ""
  alias_name             = ""
  evaluate_target_health = false
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
