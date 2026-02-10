variable "config" {
  description = "List of configuration variables to add to AWS SSM Parameter Store"

  default = {
    variables = []
  }

  type = object({
    variables = list(object({
      path  = string
      key   = string
      value = string
    }))
  })
}

variable "network" {
  description = ""
  default     = []
  nullable    = false

  type = list(object({
    name              = string
    availability_zone = list(string)

    vpc_cidr_block            = string
    subnet_cidr_block_private = list(string)
    subnet_cidr_block_public  = list(string)

    alb_domain_name_alias         = string
    alb_domain_name_alias_zone_id = string

    alb_sg_rule = list(object({
      name        = string
      type        = string
      protocol    = string
      cidr_blocks = list(string)
      port        = number
    }))

    alb_target_groups = list(object({
      id                    = string
      name                  = string
      domain_name           = string
      port                  = number
      acm_certificate_arn   = string
      alb_health_check_path = string
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

    fs_cors_origins = list(string)

    ec2_image_id      = string
    ec2_instance_type = string

    asg_min     = number
    asg_max     = number
    asg_desired = number

    log_group_name     = string
    log_stream_prefix  = string
    log_retention_days = number

    sb_compute = bool
    sb_storage = bool
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
      network_name  = string
      platform_name = string

      name   = string
      region = string

      port                = number
      domain_name         = string
      alb_target_group_id = string

      task_cpu    = number
      task_memory = number
      task_image  = string

      ecs_svc_desired_tasks_count = number
      ecs_svc_min_health_perc     = number
      ecs_svc_max_health_perc     = number
    }))

    batch = list(object({
      network_name  = string
      platform_name = string

      name   = string
      region = string

      task_cpu    = number
      task_memory = number
      task_image  = string

      ecs_svc_desired_tasks_count = number
      ecs_svc_min_health_perc     = number
      ecs_svc_max_health_perc     = number
    }))

    web = list(object({
      name                = string
      hosted_zone_id      = string
      acm_certificate_arn = string
      domain_name         = string
      index_page          = string
      error_page          = string
    }))
  })
}
