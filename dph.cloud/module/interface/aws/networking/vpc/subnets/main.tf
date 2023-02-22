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

variable "cidr_block" {
  type        = list(string)
  default     = []
  description = "List of cidr_block, for every avalibility zone you want you need one. Example: 10.0.0.0/24 and 10.0.1.0/24"
}

variable "availibility_zones" {
  type        = list(string)
  default     = []
  description = "List of avalibility zones you want. Example: eu-west-1a and eu-west-1b"
}

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC id to place to subnet into"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

# Modules that allows creating a subnet inside a VPC. This module can be used to create either a private or public-facing subnet

resource "aws_subnet" "subnet" {
  count = length(var.cidr_block)

  vpc_id            = var.vpc_id
  cidr_block        = element(var.cidr_block, count.index)
  availability_zone = element(var.availibility_zones, count.index)

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

output "id_list" {
  value = aws_subnet.subnet.*.id
}

output "arn_list" {
  value = aws_subnet.subnet.*.arn
}
