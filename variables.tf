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

    sb_eip         = bool
    sb_nat_gateway = bool
    sb_alb         = bool
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
  }))
}

variable "project" {
  description = ""
  nullable    = false

  default = {
    api   = []
    batch = []
    web   = []
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
      network_name  = string
      platform_name = string

      region = string

      task_network_mode = string
      task_launch_type  = string
      task_cpu          = string
      task_memory       = string
      task_image        = string

      ecs_svc_desired_tasks_count = number
      ecs_svc_min_health_perc     = number
      ecs_svc_max_health_perc     = number
    }))

    web = list(object({
      name           = string
      hosted_zone_id = string
      domain_name    = string
      index_page     = string
      error_page     = string
    }))
  })
}
