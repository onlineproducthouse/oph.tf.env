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

locals {
  base_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com"
}

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
    force_delete = false
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "docker" {
  value = {
    base_url = local.base_url

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
}
