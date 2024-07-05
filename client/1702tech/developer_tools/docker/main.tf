#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/docker/terraform.tfstate"
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

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "docker" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "registries" {
  source = "../../../../module/interface/aws/containers/ecr"

  for_each = {
    for image in data.terraform_remote_state.docker.outputs.images : image.key => image
  }

  ecr = {
    name         = each.value.name
    force_delete = true
  }
}

locals {
  docker = {
    base_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com"

    images = {
      for image in data.terraform_remote_state.docker.outputs.images : image.key => {
        key  = image.key
        name = image.name

        versions = {
          main = image.versions.main == null ? null : {
            version = image.versions.main
            tag = {
              docker = "${image.name}:${image.versions.main}"
              ecr    = "${module.registries[image.key].url}:${image.versions.main}"
            }
          }

          alpine = image.versions.alpine == null ? null : {
            version = image.versions.alpine
            tag = {
              docker = "${image.name}:${image.versions.alpine}"
              ecr    = "${module.registries[image.key].url}:${image.versions.alpine}"
            }
          }
        }
      }
    }
  }

  docker_tags = chunklist(compact(flatten(concat(
    [for v in [for image in local.docker.images : image.versions.main] : v == null ? null : [for tag in v.tag : tag]],
    [for v in [for image in local.docker.images : image.versions.alpine] : v == null ? null : [for tag in v.tag : tag]]
  ))), 2)
}

resource "skopeo2_copy" "images" {
  count             = length(local.docker_tags)
  source_image      = "docker://${local.docker_tags[count.index][0]}"
  destination_image = "docker://${local.docker_tags[count.index][1]}"

  insecure         = false
  copy_all_images  = true
  preserve_digests = true
  retries          = 3
  retry_delay      = 10
  keep_image       = false
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "docker" {
  value = local.docker
}
