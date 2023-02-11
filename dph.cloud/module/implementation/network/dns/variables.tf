#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type = string
}

variable "owner" {
  type = string
}

variable "environment_name" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "domain_email_mx" {
  type = string
}
