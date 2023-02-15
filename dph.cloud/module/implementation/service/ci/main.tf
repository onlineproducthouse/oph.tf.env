#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
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
