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
    build          = bool
    build_artefact = bool
    deploy         = bool
    registry       = bool
  })

  default = {
    build          = false
    build_artefact = false
    deploy         = false
    registry       = false
  }
}
