#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "certificate" {
  type = object({
    hosted_zone_id = string
    domain_name    = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_acm_certificate" "certificate" {
  domain_name               = var.certificate.domain_name
  subject_alternative_names = ["*.${var.certificate.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

module "domain_certificate_validation_record" {
  source = "../../../networking/route53/hosted_zone/dns_record"

  for_each = {
    for dvo in aws_acm_certificate.certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(split("", dvo.domain_name), "*") != true
  }

  record = {
    with_alias = false
    zone_id    = var.certificate.hosted_zone_id

    name                   = each.value.name
    type                   = each.value.type
    records                = [each.value.record]
    ttl                    = "60"
    evaluate_target_health = false

    alias_name    = ""
    alias_zone_id = ""
  }
}

module "domain_certificate_validation" {
  source = "../certificate_validation"
  certificate_validation = {
    certificate_arn = aws_acm_certificate.certificate.arn
    cert_fqdn       = [for item in module.domain_certificate_validation_record : item.record_fqdn]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "cert_arn" {
  value = aws_acm_certificate.certificate.arn
}

output "cert_domain_name" {
  value = aws_acm_certificate.certificate.domain_name
}
