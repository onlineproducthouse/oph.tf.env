#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "network" {
  type = object({
    vpc_in_use      = bool
    vpc_cidr_block  = string
    dest_cidr_block = string

    subnets = object({
      private = object({
        cidr_block         = list(string)
        availibility_zones = list(string)
      })

      public = object({
        cidr_block         = list(string)
        availibility_zones = list(string)
      })
    })
  })

  default = {
    vpc_in_use      = false
    vpc_cidr_block  = ""
    dest_cidr_block = "0.0.0.0/0"
    subnets = {
      private = {
        availibility_zones = []
        cidr_block         = []
      }
      public = {
        availibility_zones = []
        cidr_block         = []
      }
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_vpc" "vpc" {
  count = var.network.vpc_cidr_block == "" ? 0 : 1

  cidr_block           = var.network.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    environment_name = var.client_info.environment_name
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_internet_gateway" "igw" {
  count = var.network.vpc_in_use == true ? 1 : 0

  vpc_id = aws_vpc.vpc[0].id

  tags = {
    environment_name = var.client_info.environment_name
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

module "private_subnet" {
  source = "../../../../interface/aws/networking/vpc/subnets"

  count = var.network.vpc_in_use == true ? 1 : 0

  client_info = var.client_info

  vpc_id             = aws_vpc.vpc[0].id
  availibility_zones = var.network.subnets.private.availibility_zones
  cidr_block         = var.network.subnets.private.cidr_block
}

module "public_subnet" {
  source = "../../../../interface/aws/networking/vpc/subnets"

  count = var.network.vpc_in_use == true ? 1 : 0

  client_info = var.client_info

  vpc_id             = aws_vpc.vpc[0].id
  availibility_zones = var.network.subnets.public.availibility_zones
  cidr_block         = var.network.subnets.public.cidr_block
}

module "eip" {
  source = "../../../../interface/aws/networking/vpc/elastic_ip"

  count = var.network.vpc_in_use == true ? 1 : 0

  subnet_count = length(var.network.subnets.public.cidr_block)
  client_info  = var.client_info
}

resource "aws_nat_gateway" "nat" {
  count = var.network.vpc_in_use == true ? length(module.public_subnet[0].id_list) : 0

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

  count = var.network.vpc_in_use == true ? 1 : 0

  client_info    = var.client_info
  vpc_id         = aws_vpc.vpc[0].id
  subnet_id_list = module.public_subnet[0].id_list
}

module "private_route_table" {
  source = "../../../../interface/aws/networking/vpc/route_table"

  count = var.network.vpc_in_use == true ? 1 : 0

  client_info    = var.client_info
  vpc_id         = aws_vpc.vpc[0].id
  subnet_id_list = module.private_subnet[0].id_list
}

module "public_route" {
  source = "../../../../interface/aws/networking/vpc/route_table/route"

  count = var.network.vpc_in_use == true ? length(module.public_route_table[0].route_table_id_list) : 0

  is_private = false

  route_table_id = element(module.public_route_table[0].route_table_id_list, count.index)
  igw_id         = aws_internet_gateway.igw[0].id
  nat_gateway_id = null

  destination_cidr_block = var.network.dest_cidr_block
}

module "private_route" {
  source = "../../../../interface/aws/networking/vpc/route_table/route"

  count = var.network.vpc_in_use == true ? length(module.private_route_table[0].route_table_id_list) : 0

  is_private = true

  route_table_id = element(module.private_route_table[0].route_table_id_list, count.index)
  igw_id         = null
  nat_gateway_id = element(aws_nat_gateway.nat[0].*.id, count.index)

  destination_cidr_block = var.network.dest_cidr_block
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  network = var.network.vpc_in_use == false ? {
    vpc_cidr_block = ""
    vpc_id         = ""
    eip            = []
    subnet_id_list = {
      private = []
      public  = []
    }
    } : {
    vpc_cidr_block = var.network.vpc_cidr_block
    vpc_id         = aws_vpc.vpc[0].id
    eip            = module.eip[0].eip_public_ip_list
    subnet_id_list = {
      private = module.private_subnet[0].id_list
      public  = module.public_subnet[0].id_list
    }
  }
}

output "network" {
  value = local.network
}
