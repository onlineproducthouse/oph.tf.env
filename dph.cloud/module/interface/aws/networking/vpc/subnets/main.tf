#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "environment_name" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
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
    environment_name = var.environment_name
    owner            = var.owner
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
