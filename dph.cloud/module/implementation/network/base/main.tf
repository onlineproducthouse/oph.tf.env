#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "hosted_zone" {
  source = "../../../../module/interface/aws/networking/route53/hosted_zone"

  count = var.create_dns == true ? 1 : 0

  domain_name      = var.domain_name
  owner            = var.owner
  environment_name = var.environment_name
}

module "email_mx" {
  source = "../../../../module/interface/aws/networking/route53/hosted_zone/dns_record"

  count = var.create_dns == true ? 1 : 0

  with_alias             = false
  zone_id                = module.hosted_zone[0].id
  alias_zone_id          = ""
  name                   = var.domain_name
  alias_name             = ""
  type                   = "MX"
  ttl                    = "86400"
  evaluate_target_health = false
  records                = [var.domain_email_mx]
}
