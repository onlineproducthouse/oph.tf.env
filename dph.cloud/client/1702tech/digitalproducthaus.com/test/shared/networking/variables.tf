#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type    = string
  default = ""
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

variable "cidr_block" {
  type    = string
  default = ""
}

variable "availibility_zones" {
  type    = list(string)
  default = []
}

variable "public_subnet_cidr_block" {
  type    = list(string)
  default = []
}

variable "private_subnet_cidr_block" {
  type    = list(string)
  default = []
}
