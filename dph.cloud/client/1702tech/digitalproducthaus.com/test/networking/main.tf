#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/test/networking/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                      VERSIONS                     #
#                                                   #
#####################################################

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      version = "4.8.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "base" {
  source = "../../../../../module/implementation/network/base"

  region           = var.region
  environment_name = var.environment_name
  owner            = var.owner

  vpc = {
    cidr_block = var.cidr_block
  }

  subnets = {
    private = {
      availibility_zones = var.availibility_zones
      cidr_block         = var.public_subnet_cidr_block
    }
    public = {
      availibility_zones = var.availibility_zones
      cidr_block         = var.private_subnet_cidr_block
    }
  }
}
