#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker_registries/terraform.tfstate"
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
  registries = [
    { key = "redis", name = "redis" },
    { key = "postgis", name = "postgis/postgis" },
    { key = "tonistiigibinfmt", name = "tonistiigi/binfmt" },
    { key = "golang", name = "golang" },
    { key = "node", name = "node" },
  ]
}

module "registries" {
  source = "../../../module/interface/aws/containers/ecr"

  for_each = {
    for index, registry in local.registries : registry.key => registry
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

output "registries" {
  value = {
    for index, registry in local.registries : registry.key => {
      key  = registry.key
      name = registry.name
      url  = module.registries[registry.key].url
    }
  }
}
