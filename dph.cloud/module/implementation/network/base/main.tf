#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

variable "vpc" {
  description = "Configuration required to create a VPC"

  type = object({
    cidr_block = string
  })

  default = {
    cidr_block = ""
  }
}

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
// set up eip
// set up natgw
// set up route table
// set up route

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

# output "vpc" {
#   value = {
#     id         = aws_vpc.vpc.id
#     cidr_block = aws_vpc.vpc.cidr_block
#   }
# }

# output "igw" {
#   value = {
#     id = aws_internet_gateway.igw.id
#   }
# }
