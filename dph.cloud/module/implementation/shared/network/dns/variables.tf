#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
}

variable "domain_name" {
  type = string
}

variable "domain_email_mx" {
  type = string
}
