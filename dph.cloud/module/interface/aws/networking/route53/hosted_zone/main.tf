#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "domain_name" {
  type    = string
  default = ""
}

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name

  tags = {
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
    environment_name = var.client_info.environment_name
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
