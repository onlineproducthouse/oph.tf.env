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

    network = object({
      in_use             = bool
      availibility_zones = list(string)

      cidr_blocks = object({
        vpc    = string
        public = string

        subnets = object({
          private = list(string)
          public  = list(string)
        })
      })
    })

    load_balancer = object({
      domain_name_prefix = string
      health_check_path  = string

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

    compute = object({})

    container = object({
      launch_type               = string
      enable_container_insights = bool
      network_mode              = string
      log_group                 = string

      cpu    = number
      memory = number

      desired_tasks_count                = number
      target_capacity                    = number
      deployment_minimum_healthy_percent = number
      deployment_maximum_healthy_percent = number
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
    role          = local.role_output
    network       = local.network_output
    load_balancer = local.lb_output
    container     = local.container_output
  }
}
