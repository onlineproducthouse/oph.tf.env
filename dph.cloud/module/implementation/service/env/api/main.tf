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
    name             = string
    port             = number
    content_store_id = string

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

    compute = object({
      instance = object({
        image_id      = string
        instance_type = string
      })

      auto_scaling = object({
        minimum = number
        maximum = number
        desired = number
      })
    })

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

locals {
  config = {
    cluster_name           = "${var.api.name}-cluster"
    task_definition_family = "${var.api.name}-task-family"
    container_name         = "${var.api.name}-container"
    service_name           = "${var.api.name}-service"
    port_mapping_name      = "${var.api.name}-port"

    full_domain_name = "${var.api.load_balancer.domain_name_prefix}.${var.api.load_balancer.listener.certificate.domain_name}"

    logging = {
      driver = "awslogs"
      prefix = "ecs"
      group  = var.api.container.log_group
    }
  }

  cloud_watch_log_group_list = [
    { key = "main", value = local.config.logging.group },
  ]
}

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
