variable "network" {
  description = ""
  default     = []
  nullable    = false

  type = list(object({
    name                      = string
    availability_zone         = list(string)
    vpc_cidr_block            = string
    subnet_cidr_block_private = list(string)
    subnet_cidr_block_public  = list(string)

    alb_sg_rule = list(object({
      name        = string
      type        = string
      protocol    = string
      cidr_blocks = list(string)
      port        = number
    }))
  }))
}

variable "platform" {
  description = ""
  default     = []
  nullable    = false

  type = list(object({
    name         = string
    network_name = string

    cw_log_retention_days = number

    ec2_image_id      = string
    ec2_instance_type = string

    asg_min     = number
    asg_max     = number
    asg_desired = number

    cluster_sg_rule = list(object({
      name        = string
      type        = string
      protocol    = string
      cidr_blocks = list(string)
      from_port   = number
      to_port     = number
    }))

    fs_cors_config_rule = list(object({
      allowed_headers = list(string)
      allowed_methods = list(string)
      allowed_origins = list(string)
      expose_headers  = list(string)
      max_age_seconds = number
    }))
  }))
}

variable "project" {
  description = ""
  nullable    = false

  default = {
    api   = []
    batch = []
    www   = []
  }

  type = object({
    api = list(object({
      name          = string
      network_name  = string
      platform_name = string

      region         = string
      hosted_zone_id = string

      port        = number
      domain_name = string

      alb_health_check_path = string

      cluster_role_arn = string

      task_network_mode = string
      task_launch_type  = string
      task_cpu          = string
      task_memory       = string
      task_image        = string

      ecs_svc_desired_tasks_count = string
      ecs_svc_min_health_perc     = string
      ecs_svc_max_health_perc     = string
    }))

    batch = list(object({
      name          = string
      platform_name = string

      region                      = string
      asg_name                    = string
      cluster_id                  = string
      cluster_role_arn            = string
      task_network_mode           = string
      task_launch_type            = string
      task_cpu                    = string
      task_memory                 = string
      task_image                  = string
      cw_log_group                = string
      ecs_svc_desired_tasks_count = string
      ecs_svc_min_health_perc     = string
      ecs_svc_max_health_perc     = string
    }))

    www = list(object({
      hosted_zone_id = string
      domain_name    = string
      index_page     = string
      error_page     = string
    }))
  })
}
