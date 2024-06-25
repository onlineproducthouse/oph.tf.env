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

data "terraform_remote_state" "registries" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker_registries/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  golang = {
    name = "golang"
    url  = data.terraform_remote_state.registries.outputs.registries.golang.url
    versions = {
      main   = "1.22.4"
      alpine = "1.22.4-alpine"
    }
  }

  node = {
    name = "node"
    url  = data.terraform_remote_state.registries.outputs.registries.node.url
    versions = {
      main   = "20.14"
      alpine = "20.14-alpine"
    }
  }

  postgis = {
    name = "postgis"
    url  = data.terraform_remote_state.registries.outputs.registries.postgis.url
    versions = {
      main = "14-3.2"
    }
  }

  redis = {
    name = "redis"
    url  = data.terraform_remote_state.registries.outputs.registries.redis.url
    versions = {
      main = "latest"
    }
  }

  tonistiigibinfmt = {
    name = "tonistiigibinfmt"
    url  = data.terraform_remote_state.registries.outputs.registries.tonistiigibinfmt.url
    versions = {
      main = "latest"
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "tags" {
  value = {
    tags = {
      golang = {
        main   = "${local.golang.url}:${local.golang.versions.main}"
        alpine = "${local.golang.url}:${local.golang.versions.alpine}"
      }

      node = {
        main   = "${local.node.url}:${local.node.versions.main}"
        alpine = "${local.node.url}:${local.node.versions.alpine}"
      }

      postgis = {
        main = "${local.postgis.url}:${local.postgis.versions.main}"
      }

      redis = {
        main = "${local.redis.url}:${local.redis.versions.main}"
      }

      tonistiigibinfmt = {
        main = "${local.tonistiigibinfmt.url}:${local.tonistiigibinfmt.versions.main}"
      }
    }
  }
}
