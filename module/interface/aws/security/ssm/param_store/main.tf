#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

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

resource "aws_ssm_parameter" "parameters" {
  for_each = {
    for index, parameter in var.parameters : parameter.id => parameter
  }

  name  = "${each.value.path}/${each.value.key}"
  type  = "SecureString"
  value = each.value.value
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ssm_params" {
  value = aws_ssm_parameter.parameters
}
