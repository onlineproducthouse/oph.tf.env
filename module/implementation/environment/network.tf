#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_vpc" "environment" {
  count                = var.environment.run == true ? 1 : 0
  cidr_block           = var.environment.network.cidr_blocks.vpc
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "environment" {
  count  = length(aws_vpc.environment) > 0 ? 1 : 0
  vpc_id = aws_vpc.environment[0].id
}

module "private_subnet" {
  source = "../../interface/aws/networking/vpc/subnets"
  count  = length(aws_vpc.environment) > 0 ? 1 : 0

  subnets = {
    vpc_id             = aws_vpc.environment[0].id
    availibility_zones = var.environment.network.availibility_zones
    cidr_block         = var.environment.network.cidr_blocks.subnets.private
  }
}

module "public_subnet" {
  source = "../../interface/aws/networking/vpc/subnets"
  count  = length(aws_vpc.environment) > 0 ? 1 : 0

  subnets = {
    vpc_id             = aws_vpc.environment[0].id
    availibility_zones = var.environment.network.availibility_zones
    cidr_block         = var.environment.network.cidr_blocks.subnets.public
  }
}

module "eip" {
  source = "../../interface/aws/networking/vpc/elastic_ip"
  count  = length(module.public_subnet) > 0 ? 1 : 0

  elastic_ip = {
    subnet_count = length(module.public_subnet[0].id_list)
  }
}

resource "aws_nat_gateway" "environment" {
  count         = length(module.public_subnet) > 0 ? length(module.public_subnet[0].id_list) : 0
  allocation_id = element(module.eip[0].eip_nat_id_list, count.index)
  subnet_id     = element(module.public_subnet[0].id_list, count.index)
}

module "public_route_table" {
  source = "../../interface/aws/networking/vpc/route_table"
  count  = length(module.public_subnet) > 0 ? 1 : 0

  route_table = {
    vpc_id         = aws_vpc.environment[0].id
    subnet_id_list = module.public_subnet[0].id_list
  }
}

module "private_route_table" {
  source = "../../interface/aws/networking/vpc/route_table"
  count  = length(module.private_subnet) > 0 ? 1 : 0

  route_table = {
    vpc_id         = aws_vpc.environment[0].id
    subnet_id_list = module.private_subnet[0].id_list
  }
}

module "public_route" {
  source = "../../interface/aws/networking/vpc/route_table/route"
  count  = length(module.public_subnet) > 0 ? length(module.public_route_table[0].route_table_id_list) : 0

  route = {
    is_private = false

    route_table_id = element(module.public_route_table[0].route_table_id_list, count.index)
    igw_id         = aws_internet_gateway.environment[0].id
    nat_gateway_id = null

    destination_cidr_block = var.environment.network.cidr_blocks.public
  }
}

module "private_route" {
  source = "../../interface/aws/networking/vpc/route_table/route"
  count  = length(module.private_subnet) > 0 ? length(module.private_route_table[0].route_table_id_list) : 0

  route = {
    is_private = true

    route_table_id = element(module.private_route_table[0].route_table_id_list, count.index)
    igw_id         = null
    nat_gateway_id = element(aws_nat_gateway.environment[0].*.id, count.index)

    destination_cidr_block = var.environment.network.cidr_blocks.public
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  null_network_output = {
    in_use = false

    vpc = {
      id         = ""
      cidr_block = ""
    }

    eip = []

    subnet_id_list = {
      private = []
      public  = []
    }
  }
}

locals {
  network_output = var.environment.run == true ? {
    in_use = var.environment.run

    vpc = {
      id         = aws_vpc.environment[0].id
      cidr_block = var.environment.network.cidr_blocks.vpc
    }

    eip = module.eip[0].eip_public_ip_list

    subnet_id_list = {
      private = module.private_subnet[0].id_list
      public  = module.public_subnet[0].id_list
    }
  } : local.null_network_output
}
