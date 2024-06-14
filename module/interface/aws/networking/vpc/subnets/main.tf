#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "subnets" {
  type = object({
    cidr_block         = list(string)
    availibility_zones = list(string)
    vpc_id             = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

# Modules that allows creating a subnet inside a VPC. This module can be used to create either a private or public-facing subnet

resource "aws_subnet" "subnet" {
  count = length(var.subnets.cidr_block)

  vpc_id            = var.subnets.vpc_id
  cidr_block        = element(var.subnets.cidr_block, count.index)
  availability_zone = element(var.subnets.availibility_zones, count.index)
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
