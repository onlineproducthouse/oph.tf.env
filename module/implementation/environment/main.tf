#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "environment" {
  type = object({
    run = bool

    name         = string
    region       = string
    owner_name   = string
    project_name = string
    service_name = string

    storage = {
      db_cert_key         = string
      db_cert_source_path = string
    }

    logs = {
      group = string
    }

    network = {
      availibility_zones = list(string)

      cidr_blocks = object({
        vpc    = string
        public = string

        subnets = object({
          private = list(string)
          public  = list(string)
        })
      })
    }

    load_balancer = object({
      security_group_rules = list(object({
        name        = string
        type        = string
        protocol    = string
        cidr_blocks = list(string)
        port        = number
      }))
    })

    compute = object({
      enable_container_insights = bool
      target_capacity           = number

      instance = object({
        image_id      = string
        instance_type = string
      })

      auto_scaling = object({
        minimum = number
        maximum = number
        desired = number
      })

      security_group_rules = list(object({
        name        = string
        type        = string
        protocol    = string
        cidr_blocks = list(string)
        from_port   = number
        to_port     = number
      }))
    })
  })
}

variable "api" {
  type = list(object({
    name = string
    port = number

    load_balancer = object({
      health_check_path = string

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
      network_mode = string
      launch_type  = string

      cpu    = number
      memory = number

      desired_tasks_count                = number
      deployment_minimum_healthy_percent = number
      deployment_maximum_healthy_percent = number
    })
  }))
}

variable "web" {
  type = list(object({
    name = string

    host = {
      index_page = string
      error_page = string
    }

    cdn = {
      hosted_zone_id = string

      certificate = object({
        arn         = string
        domain_name = string
      })
    }
  }))
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  shared_name = "${var.environment.owner_name}-${var.environment.project_name}-${var.environment.service_name}-${var.environment.name}"
}

module "api" {
  source = "./api"

  for_each = {
    for index, app in var.api : app.name => api
  }

  api = {
    run = var.environment.run

    name   = "${local.shared_name}-${app.name}"
    region = var.environment.region
    vpc_id = local.network_output.vpc.id
    port   = each.value.port

    aws_autoscaling_group = {
      name = local.compute_output.auto_scaling_group.name
    }

    load_balancer = {
      arn      = local.load_balancer_output.arn
      dns_name = local.load_balancer_output.dns_name
      zone_id  = local.load_balancer_output.zone_id

      health_check_path = each.value.load_balancer.health_check_path
      hosted_zone       = each.value.load_balancer.hosted_zone
      listener          = each.value.load_balancer.listener
    }

    container = {
      name                               = "${local.shared_name}-container"
      role_arn                           = local.role_output.arn
      network_mode                       = each.value.container.network_mode
      launch_type                        = each.value.container.launch_type
      cluster_id                         = local.compute_output.cluster_id
      logging                            = local.logs_output.logging
      cpu                                = each.value.container.cpu
      memory                             = each.value.container.memory
      desired_tasks_count                = each.value.container.desired_tasks_count
      deployment_minimum_healthy_percent = each.value.container.deployment_minimum_healthy_percent
      deployment_maximum_healthy_percent = each.value.container.deployment_maximum_healthy_percent
    }
  }
}

module "web" {
  source = "./web"

  for_each = {
    for index, app in var.web : app.name => app
  }

  web = {
    run  = var.environment.run
    host = each.value.host
    cdn  = each.value.cdn
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "environment" {
  value = {
    storage       = local.storage_output
    file_service  = local.file_service_output
    role          = local.role_output
    logs          = local.logs_output
    network       = local.network_output
    load_balancer = local.load_balancer_output
    compute       = local.compute_output
  }
}

output "api" {
  value = module.api
}

output "web" {
  value = module.web
}
