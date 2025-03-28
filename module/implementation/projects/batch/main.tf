#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "batch" {
  type = object({
    run = bool

    region = string
    name   = string
    vpc_id = string

    aws_autoscaling_group = object({
      name = string
    })

    container = object({
      name         = string
      role_arn     = string
      network_mode = string
      launch_type  = string
      cluster_id   = string

      cpu    = number
      memory = number

      desired_tasks_count                = number
      deployment_minimum_healthy_percent = number
      deployment_maximum_healthy_percent = number

      logging = object({
        driver = string
        prefix = string
        group  = string
      })
    })
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

output "batch" {
  value = {
    container = local.container_output
  }
}
