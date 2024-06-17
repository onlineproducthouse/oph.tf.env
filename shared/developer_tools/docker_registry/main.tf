#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/docker_registry/terraform.tfstate"
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
  registries = [
    { name = "redis" },
    { name = "postgis/postgis" },
    { name = "tonistiigi/binfmt" },
    { name = "golang" },
    { name = "node" },
  ]
}

module "registries" {
  source = "../../../module/interface/aws/containers/ecr"

  for_each = {
    for index, registry in local.registries : registry.name => registry
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

output "registry" {
  value = {
    for index, registry in local.registries : registry.name => {
      url = module.registries[registry.name].url
    }
  }
}
