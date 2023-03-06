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

variable "port" {
  type    = number
  default = -1
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################


#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "port" {
  value = var.port
}
