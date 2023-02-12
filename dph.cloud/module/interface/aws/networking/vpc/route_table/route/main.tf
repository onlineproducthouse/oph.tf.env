#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "is_private" {
  type    = bool
  default = false
}

variable "route_table_id" {
  type    = string
  default = ""
}

variable "nat_gateway_id" {
  type    = string
  default = ""
}

variable "igw_id" {
  type    = string
  default = ""
}

variable "destination_cidr_block" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route" "public" {
  count = var.is_private == true ? 0 : 1

  route_table_id         = var.route_table_id
  gateway_id             = var.igw_id
  destination_cidr_block = var.destination_cidr_block
}

resource "aws_route" "private" {
  count = var.is_private == true ? 1 : 0

  route_table_id         = var.route_table_id
  nat_gateway_id         = var.nat_gateway_id
  destination_cidr_block = var.destination_cidr_block
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
