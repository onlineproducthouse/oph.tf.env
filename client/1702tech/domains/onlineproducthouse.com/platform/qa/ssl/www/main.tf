#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/qa/ssl/www/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/dns/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  dns = {
    domain_name    = data.terraform_remote_state.dns.outputs.dns.domain_name
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  }

  certs = [
    {
      name           = "www",
      hosted_zone_id = local.dns.hosted_zone_id,
      domain_name    = "qa.${local.dns.domain_name}",
    }
  ]
}

module "cert" {
  source = "../../../../../../../../module/interface/aws/security/acm/certificate"

  for_each = {
    for cert in local.certs : cert.name => cert
  }

  certificate = {
    hosted_zone_id = each.value.hosted_zone_id
    domain_name    = each.value.domain_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "certs" {
  value = module.cert
}
