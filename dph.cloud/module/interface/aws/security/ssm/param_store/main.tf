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

variable "parameters" {
  type = list(object({
    id    = string
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
    for index, parameter in var.parameters : parameter.id => parameter
  }

  name      = "${each.value.path}/${each.value.key}"
  type      = "SecureString"
  value     = each.value.value
  overwrite = true

  tags = {
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
    environment_name = var.client_info.environment_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ssm_params" {
  value = aws_ssm_parameter.variable
}
