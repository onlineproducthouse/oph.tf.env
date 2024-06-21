#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "dns" {
  type = object({
    domain_name     = string
    domain_email_mx = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "hosted_zone" {
  source = "../../interface/aws/networking/route53/hosted_zone"
  hosted_zone = {
    domain_name = var.dns.domain_name
  }
}

module "email_mx" {
  source = "../../interface/aws/networking/route53/hosted_zone/dns_record"

  record = {
    with_alias             = false
    zone_id                = module.hosted_zone.id
    alias_zone_id          = ""
    name                   = var.dns.domain_name
    alias_name             = ""
    type                   = "MX"
    ttl                    = "86400"
    evaluate_target_health = false
    records                = [var.dns.domain_email_mx]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "hosted_zone_id" {
  value = module.hosted_zone.id
}

output "domain_name_servers" {
  value = module.hosted_zone.name_servers
}

output "domain_name" {
  value = var.dns.domain_name
}
