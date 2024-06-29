#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "ssl" {
  source = "../../interface/aws/security/acm/certificate"

  for_each = {
    for i, v in var.platform.ssl : v.key => v
  }

  certificate = {
    region         = each.value.region
    hosted_zone_id = var.platform.dns.hosted_zone_id
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
