#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/password/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

variable "password" {
  type = object({
    minimum_password_length        = number
    require_lowercase_characters   = bool
    require_numbers                = bool
    require_uppercase_characters   = bool
    require_symbols                = bool
    allow_users_to_change_password = bool
    hard_expiry                    = bool
    max_password_age               = number
    password_reuse_prevention      = number
  })

  default = {
    minimum_password_length        = 8
    require_lowercase_characters   = true
    require_numbers                = true
    require_uppercase_characters   = true
    require_symbols                = true
    allow_users_to_change_password = true
    hard_expiry                    = false
    max_password_age               = 30
    password_reuse_prevention      = 24
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_account_password_policy" "password" {
  minimum_password_length        = var.password.minimum_password_length
  require_lowercase_characters   = var.password.require_lowercase_characters
  require_numbers                = var.password.require_numbers
  require_uppercase_characters   = var.password.require_uppercase_characters
  require_symbols                = var.password.require_symbols
  allow_users_to_change_password = var.password.allow_users_to_change_password
  hard_expiry                    = var.password.hard_expiry
  max_password_age               = var.password.max_password_age
  password_reuse_prevention      = var.password.password_reuse_prevention
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
