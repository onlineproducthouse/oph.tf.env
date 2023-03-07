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

    compute = object({
      auto_scaling_group = object({
        min_instances     = number
        max_instances     = number
        desired_instances = number
      })

      launch_configuration = object({
        image_id      = string
        instance_type = string
      })
    })

    load_balancer = object({
      domain_name_prefix = string

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
  })
}

variable "web" {
  type = list(object({
    name = string

    host = object({
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
    enable_container_insights = false
    name                      = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}-cluster"
  }

  compute = {
    auto_scaling_group = var.api.compute.auto_scaling_group
    launch_configuration = {
      name          = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}-lc"
      image_id      = var.api.compute.launch_configuration.image_id
      instance_type = var.api.compute.launch_configuration.instance_type
    }
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
