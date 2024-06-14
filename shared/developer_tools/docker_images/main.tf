#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker_images/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    owner_name       = string
    owner_short_name = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  images = [
    { name = "redis-alpine", version = "7.0.15" },
    { name = "postgis/postgis", version = "14-3.2" },
    { name = "tonistiigi/binfmt", version = "latest" },
    { name = "golang-alpine", version = "1.22" },
    { name = "node-alpine", version = "20.14" },
    { name = "node", version = "20.14" },
  ]
}

module "images" {
  source = "../../../module/interface/aws/containers/ecr"

  for_each = {
    for index, image in local.images : image.name => image
  }

  ecr = {
    name = each.value.name
  }
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
