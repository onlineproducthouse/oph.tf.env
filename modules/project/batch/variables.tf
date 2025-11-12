variable "name" {
  description = "The name of the Batch project"
  type        = string
  nullable    = false
}

variable "region" {
  description = "The region where the Batch project runs from"
  type        = string
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

variable "task_network_mode" {
  description = "Network mode"
  type        = string
  nullable    = false
}

variable "task_launch_type" {
  description = "Launch type"
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

variable "cw_log_group" {
  description = "AWS CloudWatch Log Group"
  type        = string
  nullable    = false
}

variable "ecs_svc_desired_tasks_count" {
  description = "Desired number of tasks to run for Batch processor"
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
