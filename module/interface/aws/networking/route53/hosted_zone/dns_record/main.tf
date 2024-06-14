#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "record" {
  type = object({
    with_alias             = bool
    zone_id                = string
    name                   = string
    alias_name             = string
    alias_zone_id          = string
    type                   = string
    ttl                    = number
    evaluate_target_health = bool
    records                = list(string)
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route53_record" "record" {
  count = var.record.with_alias == true ? 0 : 1

  zone_id = var.record.zone_id
  name    = var.record.name
  type    = var.record.type
  ttl     = var.record.ttl
  records = var.record.records
}

resource "aws_route53_record" "alias_record" {
  count = var.record.with_alias == true ? 1 : 0

  zone_id = var.record.zone_id
  name    = var.record.name
  type    = var.record.type

  alias {
    name                   = var.record.alias_name
    zone_id                = var.record.alias_zone_id
    evaluate_target_health = var.record.evaluate_target_health
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "record_fqdn" {
  value = var.record.with_alias == true ? aws_route53_record.alias_record[0].fqdn : aws_route53_record.record[0].fqdn
}
