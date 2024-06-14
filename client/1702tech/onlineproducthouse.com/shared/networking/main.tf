#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/shared/networking/terraform.tfstate"
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

    owner_name       = string
    owner_short_name = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

variable "networking" {
  type = object({
    domain_name = string
    email_mx    = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "dns" {
  source = "../../../../../module/implementation/shared/network/dns"

  dns = {
    domain_name     = var.networking.domain_name
    domain_email_mx = var.networking.email_mx
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
