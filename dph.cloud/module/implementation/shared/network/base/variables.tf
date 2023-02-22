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

variable "dest_cidr_block" {
  type    = string
  default = "0.0.0.0/0"
}

variable "vpc" {
  description = "Configuration required to create a VPC"

  type = object({
    cidr_block = string
  })

  default = {
    cidr_block = ""
  }
}

variable "subnets" {
  description = "Configuration required for public and private subnets"

  type = object({
    private = object({
      cidr_block         = list(string)
      availibility_zones = list(string)
    })

    public = object({
      cidr_block         = list(string)
      availibility_zones = list(string)
    })
  })
}
