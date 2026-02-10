variable "name" {
  description = "The name of the API project"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The region where the API project runs from"
  type        = string
  nullable    = false
}

variable "port" {
  description = "The port that will be exposed for API"
  type        = number
  nullable    = false
}

variable "domain_name" {
  description = "The API domain name"
  type        = string
  nullable    = false
}

variable "alb_target_group_arn" {
  description = "ARN for application load balancer target group"
  type        = string
  default     = ""
  nullable    = false
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
  default     = ""
  nullable    = false
}

variable "cluster_id" {
  description = "AWS ECS Cluster ID"
  type        = string
  nullable    = false
}

variable "cluster_role_arn" {
  description = "AWS IAM Role ARN for ECS cluster"
  type        = string
  nullable    = false
}

variable "task_cpu" {
  description = "CPU"
  type        = number
  nullable    = false
}

variable "task_memory" {
  description = "Memory"
  type        = number
  nullable    = false
}

variable "task_image" {
  description = "Docker image"
  type        = string
  nullable    = false
}

variable "log_group_name" {
  description = "AWS CloudWatch log group name"
  type        = string
  default     = ""
  nullable    = false
}

variable "log_stream_prefix" {
  description = "AWS CloudWatch log stream prefix"
  type        = string
  default     = ""
  nullable    = false
}

variable "ecs_svc_desired_tasks_count" {
  description = "Desired number of tasks to run for API"
  type        = number
  nullable    = false
}

variable "ecs_svc_min_health_perc" {
  description = "Deployment minimum healthy percentage"
  type        = number
  nullable    = false
}

variable "ecs_svc_max_health_perc" {
  description = "Deployment maximum healthy percentage"
  type        = number
  nullable    = false
}
