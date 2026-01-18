variable "config" {
  description = "List of configuration variables to add to AWS SSM Parameter Store"

  default = {
    ssm_param_path   = ""
    fs_platform_name = ""
    variables        = []
  }

  type = object({
    ssm_param_path   = string
    fs_platform_name = string

    variables = list(object({
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

    sb_cloudwatch = bool
    sb_iam        = bool
    sb_compute    = bool
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

      task_cpu    = number
      task_memory = number
      task_image  = string

      ecs_svc_desired_tasks_count = number
      ecs_svc_min_health_perc     = number
      ecs_svc_max_health_perc     = number
    }))

    batch = list(object({
      name          = string
      network_name  = string
      platform_name = string

      region = string

      task_cpu    = number
      task_memory = number
      task_image  = string

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
