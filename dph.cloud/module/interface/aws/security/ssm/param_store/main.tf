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

variable "parameters" {
  type = list(object({
    path  = string
    key   = string
    value = string
  }))
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_ssm_parameter" "variable" {
  for_each = {
    for index, parameter in var.parameters : lower(parameter.key) => parameter
  }

  name      = "${each.value.path}/${each.value.key}"
  type      = "SecureString"
  value     = each.value.value
  overwrite = true

  tags = {
    owner            = var.owner
    environment_name = var.environment_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
