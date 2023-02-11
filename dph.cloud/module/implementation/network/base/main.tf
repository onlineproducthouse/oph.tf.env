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
// set up route table
// set up route
