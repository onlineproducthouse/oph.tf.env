#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/dns/terraform.tfstate"
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

variable "dns" {
  type = object({
    domain_name = string
    email_mx    = string
    ip_address  = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "dns" {
  source = "../../../../../module/implementation/dns"

  dns = {
    domain_name     = var.dns.domain_name
    domain_email_mx = var.dns.email_mx
  }
}

locals {
  records = [
    { name = "root", value = module.dns.domain_name },
    { name = "www", value = "www.${module.dns.domain_name}" }
  ]
}

module "root" {
  source = "../../../../../module/interface/aws/networking/route53/hosted_zone/dns_record"

  for_each = {
    for index, record in local.records : record.name => record
  }

  record = {
    with_alias             = false
    zone_id                = module.dns.hosted_zone_id
    alias_zone_id          = ""
    name                   = each.value.value
    alias_name             = ""
    type                   = "A"
    ttl                    = "14401"
    evaluate_target_health = false
    records                = [var.dns.ip_address]
  }
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
