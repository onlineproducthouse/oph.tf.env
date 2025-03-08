#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker/terraform.tfstate"
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

locals {
  images = [
    {
      key  = "golang"
      name = "golang"
      versions = {
        main   = "1.23.2"
        alpine = "1.23.2-alpine"
      }
    },
    {
      key  = "node"
      name = "node"
      versions = {
        main   = "22.13.1"
        alpine = "22.13.1-alpine3.21"
      }
    },
    {
      key  = "postgis"
      name = "postgis/postgis"
      versions = {
        main   = "14-3.2"
        alpine = null
      }
    },
    {
      key  = "redis"
      name = "redis"
      versions = {
        main   = "latest"
        alpine = null
      }
    },
    {
      key  = "tonistiigibinfmt"
      name = "tonistiigi/binfmt"
      versions = {
        main   = "latest"
        alpine = null
      }
    },
  ]

  # images = {
  #   for registry in local.registries : registry.key => {
  #     key  = registry.key
  #     name = registry.name
  #     versions = {
  #       main   = registry.versions.main
  #       alpine = registry.versions.alpine
  #     }
  #   }
  # }
}

output "images" {
  value = local.images
}
