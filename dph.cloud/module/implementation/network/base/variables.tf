#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
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
