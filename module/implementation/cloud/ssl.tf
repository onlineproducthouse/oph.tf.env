#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "ssl" {
  source = "../../interface/aws/security/acm/certificate"

  for_each = {
    for index, domain in var.cloud.ssl : domain.key => domain
  }

  certificate = {
    region         = each.value.region
    hosted_zone_id = var.cloud.dns.hosted_zone_id
    domain_name    = each.value.domain_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  ssl_output = {
    for index, domain in var.cloud.ssl : domain.key => {
      cert_arn         = module.ssl[domain.key].cert_arn
      cert_domain_name = module.ssl[domain.key].cert_domain_name
    }
  }
}
