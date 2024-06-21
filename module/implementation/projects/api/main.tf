#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "api" {
  type = object({
    run = bool

    region = string
    name   = string
    vpc_id = string
    port   = number

    aws_autoscaling_group = object({
      name = string
    })

    load_balancer = object({
      arn               = string
      health_check_path = string
      dns_name          = string
      zone_id           = string

      hosted_zone = object({
        id = string
      })

      listener = object({
        certificate = object({
          arn         = string
          domain_name = string
        })
      })
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

output "api" {
  value = {
    port          = var.api.port
    load_balancer = local.lb_output
    container     = local.container_output
  }
}
