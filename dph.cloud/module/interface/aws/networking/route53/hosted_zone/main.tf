#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "domain_name" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = {
    owner            = var.owner
    environment_name = var.environment_name
  }
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
