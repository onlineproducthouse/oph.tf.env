#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_vpc" "api" {
  count = var.api.network.cidr_blocks.vpc == "" ? 0 : 1

  cidr_block           = var.api.network.cidr_blocks.vpc
  enable_dns_hostnames = true

  tags = {
    environment_name = var.client_info.environment_name
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_internet_gateway" "api" {
  count = var.api.network.in_use == true && length(aws_vpc.api) > 0 ? 1 : 0

  vpc_id = aws_vpc.api[0].id

  tags = {
    environment_name = var.client_info.environment_name
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

module "private_subnet" {
  source = "../../../../interface/aws/networking/vpc/subnets"

  count = var.api.network.in_use == true && length(aws_vpc.api) > 0 ? 1 : 0

  client_info = var.client_info

  vpc_id             = aws_vpc.api[0].id
  availibility_zones = var.api.network.availibility_zones
  cidr_block         = var.api.network.cidr_blocks.subnets.private
}

module "public_subnet" {
  source = "../../../../interface/aws/networking/vpc/subnets"

  count = var.api.network.in_use == true && length(aws_vpc.api) > 0 ? 1 : 0

  client_info = var.client_info

  vpc_id             = aws_vpc.api[0].id
  availibility_zones = var.api.network.availibility_zones
  cidr_block         = var.api.network.cidr_blocks.subnets.public
}

module "eip" {
  source = "../../../../interface/aws/networking/vpc/elastic_ip"

  count = length(module.public_subnet) > 0 ? 1 : 0

  subnet_count = length(module.public_subnet[0].id_list)
  client_info  = var.client_info
}

resource "aws_nat_gateway" "nat" {
  count = length(module.public_subnet) > 0 ? length(module.public_subnet[0].id_list) : 0

  allocation_id = element(module.eip[0].eip_nat_id_list, count.index)
  subnet_id     = element(module.public_subnet[0].id_list, count.index)

  tags = {
    resource_name    = "AWS NAT Gateway for ${element(module.public_subnet[0].id_list, count.index)}"
    environment_name = var.client_info.environment_name
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

module "public_route_table" {
  source = "../../../../interface/aws/networking/vpc/route_table"

  count = length(module.public_subnet) > 0 ? 1 : 0

  client_info    = var.client_info
  vpc_id         = aws_vpc.api[0].id
  subnet_id_list = module.public_subnet[0].id_list
}

module "private_route_table" {
  source = "../../../../interface/aws/networking/vpc/route_table"

  count = length(module.private_subnet) > 0 ? 1 : 0

  client_info    = var.client_info
  vpc_id         = aws_vpc.api[0].id
  subnet_id_list = module.private_subnet[0].id_list
}

module "public_route" {
  source = "../../../../interface/aws/networking/vpc/route_table/route"

  count = length(module.public_route_table) > 0 ? length(module.public_route_table[0].route_table_id_list) : 0

  is_private = false

  route_table_id = element(module.public_route_table[0].route_table_id_list, count.index)
  igw_id         = aws_internet_gateway.api[0].id
  nat_gateway_id = null

  destination_cidr_block = var.api.network.cidr_blocks.public
}

module "private_route" {
  source = "../../../../interface/aws/networking/vpc/route_table/route"

  count = length(module.private_route_table) > 0 ? length(module.private_route_table[0].route_table_id_list) : 0

  is_private = true

  route_table_id = element(module.private_route_table[0].route_table_id_list, count.index)
  igw_id         = null
  nat_gateway_id = element(aws_nat_gateway.nat[0].*.id, count.index)

  destination_cidr_block = var.api.network.cidr_blocks.public
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  network_output = var.api.network.in_use == true ? {
    vpc = {
      id         = aws_vpc.api[0].id
      cidr_block = var.api.network.cidr_blocks.vpc
    }

    eip = module.eip[0].eip_public_ip_list

    subnet_id_list = {
      private = module.private_subnet[0].id_list
      public  = module.public_subnet[0].id_list
    }
    } : {
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
