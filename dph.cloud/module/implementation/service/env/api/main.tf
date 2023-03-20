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

variable "api" {
  type = object({
    name = string
    port = number

    network       = object({})
    load_balancer = object({})
    compute       = object({})
    container     = object({})
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################


#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "api" {
  value = {
    role = {
      name = aws_iam_role.api.name
      id   = aws_iam_role.api.id
      arn  = aws_iam_role.api.arn

      instance = {
        id  = aws_iam_instance_profile.api.id
        arn = aws_iam_instance_profile.api.arn
      }
    }
  }
}
