#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "hosted_zone" {
  type = object({
    domain_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route53_zone" "hosted_zone" {
  name = var.hosted_zone.domain_name
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "id" {
  value = aws_route53_zone.hosted_zone.id
}

output "name_servers" {
  value = aws_route53_zone.hosted_zone.name_servers
}
