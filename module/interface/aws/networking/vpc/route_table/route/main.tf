#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "route" {
  type = object({
    is_private             = bool
    route_table_id         = string
    nat_gateway_id         = string
    igw_id                 = string
    destination_cidr_block = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_route" "public" {
  count = var.route.is_private == true ? 0 : 1

  route_table_id         = var.route.route_table_id
  gateway_id             = var.route.igw_id
  destination_cidr_block = var.route.destination_cidr_block
}

resource "aws_route" "private" {
  count = var.route.is_private == true ? 1 : 0

  route_table_id         = var.route.route_table_id
  nat_gateway_id         = var.route.nat_gateway_id
  destination_cidr_block = var.route.destination_cidr_block
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
