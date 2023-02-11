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
