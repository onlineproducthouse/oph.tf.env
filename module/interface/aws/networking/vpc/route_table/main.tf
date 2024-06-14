#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "route_table" {
  type = object({
    vpc_id         = string
    subnet_id_list = list(string)
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

# We are creating one more subnets that we want to address as one, therefore we create a routing table and 
# add all the subnets to it. This allows us to easier create routing to all the subnets at once.
# For example when creating a route to the Internet Gateway
resource "aws_route_table" "route_table" {
  count  = length(var.route_table.subnet_id_list)
  vpc_id = var.route_table.vpc_id
}

resource "aws_route_table_association" "route_table" {
  count = length(var.route_table.subnet_id_list)

  subnet_id      = element(var.route_table.subnet_id_list, count.index)
  route_table_id = element(aws_route_table.route_table.*.id, count.index)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "route_table_id_list" {
  value = aws_route_table.route_table.*.id
}
