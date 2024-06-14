#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "connection" {
  type = object({
    name          = string
    provider_type = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codestarconnections_connection" "connection" {
  name          = var.connection.name
  provider_type = var.connection.provider_type
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "arn" {
  value = aws_codestarconnections_connection.connection.arn
}
