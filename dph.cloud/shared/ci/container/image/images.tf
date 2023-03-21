#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/container/image/terraform.tfstate"
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
  region = var.client_info.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  images = [
    { name = "redis", version = "latest" },
    { name = "postgis/postgis", version = "14-3.2" },
    { name = "tonistiigi/binfmt", version = "latest" },
    { name = "golang", version = "1.19-alpine" },
    { name = "node", version = "18.14-alpine" },
    { name = "httpd", version = "2.4" },
  ]
}

module "images" {
  source = "../../../../module/interface/aws/containers/ecr"

  for_each = {
    for index, image in local.images : image.name => image
  }

  name        = each.value.name
  client_info = var.client_info
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "images" {
  value = {
    for index, image in local.images : image.name => {
      tag_url = "${module.images[image.name].url}:${image.version}"
    }
  }
}
