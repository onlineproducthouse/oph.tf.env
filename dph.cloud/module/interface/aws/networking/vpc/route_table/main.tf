#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "vpc_id" {
  type        = string
  default     = ""
  description = "VPC id to place to subnet into"
}

variable "subnet_id_list" {
  type    = list(string)
  default = []
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

# We are creating one more subnets that we want to address as one, therefore we create a routing table and 
# add all the subnets to it. This allows us to easier create routing to all the subnets at once.
# For example when creating a route to the Internet Gateway 
resource "aws_route_table" "route_table" {
  count = length(var.subnet_id_list)

  vpc_id = var.vpc_id

  tags = {
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
    environment_name = var.client_info.environment_name
  }
}

resource "aws_route_table_association" "subnet" {
  count = length(var.subnet_id_list)

  subnet_id      = element(var.subnet_id_list, count.index)
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
