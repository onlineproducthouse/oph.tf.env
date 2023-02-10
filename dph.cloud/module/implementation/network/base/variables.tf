#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "create_dns" {
  type        = bool
  default     = false
  description = "Indicate if AWS Route53 DNS is required for custom domain"
}

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
