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

locals {
  golang = {
    key  = "golang"
    name = "golang"
    versions = {
      main   = "1.22.4"
      alpine = "1.22.4-alpine"
    }
  }

  node = {
    key  = "node"
    name = "node"
    versions = {
      main   = "20.14"
      alpine = "20.14-alpine"
    }
  }

  postgis = {
    key  = "postgis"
    name = "postgis/postgis"
    versions = {
      main = "14-3.2"
    }
  }

  redis = {
    key  = "redis"
    name = "redis"
    versions = {
      main = "latest"
    }
  }

  tonistiigibinfmt = {
    key  = "tonistiigibinfmt"
    name = "tonistiigi/binfmt"
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
    golang = {
      main = {
        docker = "${local.golang.name}:${local.golang.versions.main}",
        ecr    = "${local.golang.key}:${local.golang.versions.main}",
      }
      alpine = {
        docker = "${local.golang.name}:${local.golang.versions.alpine}",
        ecr    = "${local.golang.key}:${local.golang.versions.alpine}",
      }
    }

    node = {
      main = {
        docker = "${local.node.name}:${local.node.versions.main}",
        ecr    = "${local.node.key}:${local.node.versions.main}",
      }
      alpine = {
        docker = "${local.node.name}:${local.node.versions.alpine}",
        ecr    = "${local.node.key}:${local.node.versions.alpine}",
      }
    }

    postgis = {
      main = {
        docker = "${local.postgis.name}:${local.postgis.versions.main}",
        ecr    = "${local.postgis.key}:${local.postgis.versions.main}",
      }
    }

    redis = {
      main = {
        docker = "${local.redis.name}:${local.redis.versions.main}",
        ecr    = "${local.redis.key}:${local.redis.versions.main}",
      }
    }

    tonistiigibinfmt = {
      main = {
        docker = "${local.tonistiigibinfmt.name}:${local.tonistiigibinfmt.versions.main}",
        ecr    = "${local.tonistiigibinfmt.key}:${local.tonistiigibinfmt.versions.main}",
      }
    }
  }
}
