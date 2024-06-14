#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "certificate_validation" {
  type = object({
    certificate_arn = string
    cert_fqdn       = set(string)
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_acm_certificate_validation" "certificate_validation" {
  certificate_arn         = var.certificate_validation.certificate_arn
  validation_record_fqdns = var.certificate_validation.cert_fqdn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################


