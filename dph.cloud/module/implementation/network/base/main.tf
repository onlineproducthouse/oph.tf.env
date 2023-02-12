#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

// set up vpc
resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc.cidr_block
  enable_dns_hostnames = true

  tags = {
    environment_name = var.environment_name
    owner            = var.owner
  }
}

// set up igw
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    environment_name = var.environment_name
    owner            = var.owner
  }
}

// set up subnets
module "private_subnet" {
  source = "../../../interface/aws/networking/vpc/subnets"

  environment_name = var.environment_name
  owner            = var.owner

  vpc_id             = aws_vpc.vpc.id
  availibility_zones = var.subnets.private.availibility_zones
  cidr_block         = var.subnets.private.cidr_block
}

module "public_subnet" {
  source = "../../../interface/aws/networking/vpc/subnets"

  environment_name = var.environment_name
  owner            = var.owner

  vpc_id             = aws_vpc.vpc.id
  availibility_zones = var.subnets.public.availibility_zones
  cidr_block         = var.subnets.public.cidr_block
}

// set up eip
module "eip" {
  source = "../../../interface/aws/networking/vpc/elastic_ip"

  subnet_count = length(var.subnets.public.cidr_block)

  environment_name = var.environment_name
  owner            = var.owner
}

// set up natgw
resource "aws_nat_gateway" "nat" {
  count = length(var.subnets.public.cidr_block)

  allocation_id = element(module.eip.eip_nat_id_list, count.index)
  subnet_id     = element(module.public_subnet.id_list, count.index)

  tags = {
    resource_name    = "AWS NAT Gateway for ${element(module.public_subnet.id_list, count.index)}"
    owner            = var.owner
    environment_name = var.environment_name
  }
}

// set up route table
module "public_route_table" {
  source = "../../../interface/aws/networking/vpc/route_table"

  vpc_id         = aws_vpc.vpc.id
  subnet_id_list = module.public_subnet.id_list

  environment_name = var.environment_name
  owner            = var.owner
}

module "private_route_table" {
  source = "../../../interface/aws/networking/vpc/route_table"

  vpc_id         = aws_vpc.vpc.id
  subnet_id_list = module.private_subnet.id_list

  environment_name = var.environment_name
  owner            = var.owner
}

// set up route
module "public_route" {
  source = "../../../interface/aws/networking/vpc/route_table/route"

  count = length(module.public_route_table.route_table_id_list)

  is_private = false

  route_table_id = element(module.public_route_table.route_table_id_list, count.index)
  igw_id         = aws_internet_gateway.igw.id
  nat_gateway_id = null

  destination_cidr_block = var.dest_cidr_block
}

module "private_route" {
  source = "../../../interface/aws/networking/vpc/route_table/route"

  count = length(module.private_route_table.route_table_id_list)

  is_private = true

  route_table_id = element(module.private_route_table.route_table_id_list, count.index)
  igw_id         = null
  nat_gateway_id = element(aws_nat_gateway.nat.*.id, count.index)

  destination_cidr_block = var.dest_cidr_block
}
