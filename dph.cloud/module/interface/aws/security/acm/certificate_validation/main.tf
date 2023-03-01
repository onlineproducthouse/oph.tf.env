#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "certificate_arn" {
  type    = string
  default = ""
}

variable "cert_fqdn" {}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_acm_certificate_validation" "domain_certificate_validation" {
  certificate_arn         = var.certificate_arn
  validation_record_fqdns = var.cert_fqdn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################


