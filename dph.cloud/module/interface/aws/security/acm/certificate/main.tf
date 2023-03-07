#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

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

provider "aws" {
  region = var.client_info.region
}

resource "aws_acm_certificate" "domain_certificate" {
  domain_name               = var.certificate.domain_name
  subject_alternative_names = ["*.${var.certificate.domain_name}"]
  validation_method         = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    owner        = var.client_info.owner
    owner        = var.client_info.owner
    project_name = var.client_info.project_name
    service_name = var.client_info.service_name
  }
}

module "domain_certificate_validation_record" {
  source = "../../../networking/route53/hosted_zone/dns_record"

  for_each = {
    for dvo in aws_acm_certificate.domain_certificate.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(split("", dvo.domain_name), "*") != true
  }

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

module "domain_certificate_validation" {
  source = "../certificate_validation"

  certificate_arn = aws_acm_certificate.domain_certificate.arn
  cert_fqdn       = [for item in module.domain_certificate_validation_record : item.record_fqdn]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "cert_arn" {
  value = aws_acm_certificate.domain_certificate.arn
}

output "cert_domain_name" {
  value = aws_acm_certificate.domain_certificate.domain_name
}
