#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "name" {
  type    = string
  default = "UnknownCodeStarConn"
}

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
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

output "arn" {
  value = aws_codestarconnections_connection.conn.arn
}
