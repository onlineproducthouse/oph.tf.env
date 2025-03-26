#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_vpc" "cloud" {
  cidr_block           = var.cloud.network.cidr_blocks.vpc
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "cloud" {
  vpc_id = aws_vpc.cloud.id
}

module "subnet" {
  source = "../../interface/aws/networking/vpc/subnets"

  for_each = {
    for index, name in ["public", "private"] : name => name
  }

  subnets = {
    vpc_id             = aws_vpc.cloud.id
    availibility_zones = var.cloud.network.availibility_zones
    cidr_block         = var.cloud.network.cidr_blocks.subnets[each.value]
  }
}

module "eip" {
  source = "../../interface/aws/networking/vpc/elastic_ip"

  elastic_ip = {
    subnet_count = length(module.subnet["public"].id_list)
  }
}

resource "aws_nat_gateway" "cloud" {
  count = var.cloud.run == true ? length(module.subnet["public"].id_list) : 0

  allocation_id = element(module.eip.eip_nat_id_list, count.index)
  subnet_id     = element(module.subnet["public"].id_list, count.index)
}

module "route_table" {
  source = "../../interface/aws/networking/vpc/route_table"

  for_each = {
    for index, name in ["public", "private"] : name => name
  }

  route_table = {
    vpc_id         = aws_vpc.cloud.id
    subnet_id_list = module.subnet[each.value].id_list
  }
}

module "public_route" {
  source = "../../interface/aws/networking/vpc/route_table/route"
  count  = var.cloud.run == true ? length(module.route_table["public"].route_table_id_list) : 0

  route = {
    is_private = false

    route_table_id = element(module.route_table["public"].route_table_id_list, count.index)
    igw_id         = aws_internet_gateway.cloud.id
    nat_gateway_id = null

    destination_cidr_block = var.cloud.network.cidr_blocks.public
  }
}

module "private_route" {
  source = "../../interface/aws/networking/vpc/route_table/route"
  count  = var.cloud.run == true ? length(module.route_table["private"].route_table_id_list) : 0

  route = {
    is_private = true

    route_table_id = element(module.route_table["private"].route_table_id_list, count.index)
    igw_id         = null
    nat_gateway_id = element(aws_nat_gateway.cloud[0].*.id, count.index)

    destination_cidr_block = var.cloud.network.cidr_blocks.public
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  network_output = {
    vpc = {
      id         = aws_vpc.cloud.id
      cidr_block = var.cloud.network.cidr_blocks.vpc
    }

    eip = module.eip.eip_public_ip_list

    subnet = {
      private = {
        cidr_blocks = var.cloud.network.cidr_blocks.subnets.private
        id_list     = module.subnet["private"].id_list
      }

      public = {
        cidr_blocks = var.cloud.network.cidr_blocks.subnets.public
        id_list     = module.subnet["public"].id_list
      }
    }
  }
}
