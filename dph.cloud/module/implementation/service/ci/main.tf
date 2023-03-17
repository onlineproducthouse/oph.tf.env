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


variable "config_switch" {
  description = "Config switch allows the selection of which resources to provision"

  type = object({
    registry       = bool
    build_artefact = bool
    build          = bool
  })

  default = {
    build          = false
    build_artefact = false
    registry       = false
  }
}

variable "ci_job" {
  type = object({
    service_role    = string
    build_timeout   = string
    is_docker_build = bool
  })

  default = {
    service_role    = ""
    build_timeout   = "10"
    is_docker_build = false
  }
}

locals {
  release_manifest = "ReleaseManifest.sh"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

