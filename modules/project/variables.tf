variable "api" {
  description = "Variables required by the API module"
  default     = []
  nullable    = false

  type = list(object({
    name                        = string
    region                      = string
    vpc_id                      = string
    hosted_zone_id              = string
    port                        = number
    domain_name                 = string
    alb_arn                     = string
    alb_hosted_zone_id          = string
    alb_dns_name                = string
    alb_health_check_path       = string
    asg_name                    = string
    cluster_id                  = string
    cluster_role_arn            = string
    task_network_mode           = string
    task_launch_type            = string
    task_cpu                    = number
    task_memory                 = number
    task_image                  = string
    cw_log_group                = string
    ecs_svc_desired_tasks_count = number
    ecs_svc_min_health_perc     = number
    ecs_svc_max_health_perc     = number
  }))
}

variable "batch" {
  description = "Variables required by the Batch module"
  default     = []
  nullable    = false

  type = list(object({
    name                        = string
    region                      = string
    asg_name                    = string
    cluster_id                  = string
    cluster_role_arn            = string
    task_network_mode           = string
    task_launch_type            = string
    task_cpu                    = number
    task_memory                 = number
    task_image                  = string
    cw_log_group                = string
    ecs_svc_desired_tasks_count = number
    ecs_svc_min_health_perc     = number
    ecs_svc_max_health_perc     = number
  }))
}

variable "web" {
  description = "Variables required by the web project module"
  default     = []
  nullable    = false

  type = list(object({
    name           = string
    hosted_zone_id = string
    domain_name    = string
    index_page     = string
    error_page     = string
  }))
}
