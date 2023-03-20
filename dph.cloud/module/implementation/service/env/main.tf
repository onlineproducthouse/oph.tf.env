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

variable "content" {
  type = object({
    db_cert_source_path = string
  })
}

variable "api" {
  type = object({
    port = number

    network = object({
      vpc_in_use      = bool
      vpc_cidr_block  = string
      dest_cidr_block = string

      subnets = object({
        private = object({
          cidr_block         = list(string)
          availibility_zones = list(string)
        })

        public = object({
          cidr_block         = list(string)
          availibility_zones = list(string)
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

    cluster = object({
      enable_container_insights = bool

      ecs_service = object({
        launch_type                        = string
        desired_tasks_count                = number
        target_capacity                    = number
        deployment_minimum_healthy_percent = number
        deployment_maximum_healthy_percent = number

        container = object({
          name               = string
          cpu                = number
          memory_reservation = number
        })
      })
    })
  })
}

variable "web" {
  type = list(object({
    name = string

    host = object({
      vpc_in_use = bool
      index_page = string
      error_page = string
    })

    cdn = object({
      hosted_zone_id = string
      certificate = object({
        domain_name = string
        arn         = string
      })
    })
  }))

  default = []
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "content" {
  source      = "./content"
  client_info = var.client_info
  content     = var.content
}

module "api" {
  source = "./api"

  client_info = var.client_info

  port          = var.api.port
  network       = var.api.network
  load_balancer = var.api.load_balancer

  cluster = {
    enable_container_insights = var.api.cluster.enable_container_insights
    name                      = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}-cluster"
    service                   = var.api.cluster.ecs_service
  }
}

module "web" {
  source = "./web"

  for_each = {
    for index, app in var.web : app.name => app
  }

  client_info = var.client_info
  host        = each.value.host
  cdn         = each.value.cdn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "content" {
  value = module.content
}

output "api" {
  value = module.api
}

output "web" {
  value = module.web
}
