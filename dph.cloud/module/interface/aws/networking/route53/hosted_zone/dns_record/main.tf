#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "with_alias" {
  type    = bool
  default = false
}

variable "zone_id" {
  type    = string
  default = ""
}

variable "name" {
  type    = string
  default = ""
}

variable "alias_name" {
  type    = string
  default = ""
}

variable "alias_zone_id" {
  type    = string
  default = ""
}

variable "type" {
  type    = string
  default = ""
}

variable "ttl" {
  type    = number
  default = 0
}

variable "evaluate_target_health" {
  type    = bool
  default = false
}

variable "records" {
  type = list(string)
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route53_record" "record" {
  count = var.with_alias == true ? 0 : 1

  zone_id = var.zone_id
  name    = var.name
  type    = var.type
  ttl     = var.ttl
  records = var.records
}

resource "aws_route53_record" "record_with_alias" {
  count = var.with_alias == true ? 1 : 0

  zone_id = var.zone_id
  name    = var.name
  type    = var.type

  alias {
    name                   = var.alias_name
    zone_id                = var.alias_zone_id
    evaluate_target_health = var.evaluate_target_health
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "record_fqdn" {
  value = var.with_alias == true ? aws_route53_record.record_with_alias[0].fqdn : aws_route53_record.record[0].fqdn
}
