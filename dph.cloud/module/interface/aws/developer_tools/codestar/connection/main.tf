#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "name" {
  type    = string
  default = "UnknownCodeStarConn"
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codestarconnections_connection" "conn" {
  name          = var.name
  provider_type = "Bitbucket"

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

output "arn" {
  value = aws_codestarconnections_connection.conn.arn
}
