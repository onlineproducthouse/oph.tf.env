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

variable "vpc_id" {
  description = "VPC ID where the API project is provisioned"
  type        = string
  nullable    = false
}

variable "hosted_zone_id" {
  description = "The Route53 DNS for the API"
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

variable "alb_arn" {
  description = "ARN for application load balancer"
  type        = string
  default     = ""
  nullable    = false
}

variable "alb_hosted_zone_id" {
  description = "DNS for application load balancer"
  type        = string
  default     = ""
  nullable    = false
}

variable "alb_dns_name" {
  description = "dns name for application load balancer"
  type        = string
  default     = ""
  nullable    = false
}

variable "alb_health_check_path" {
  description = "Health check path for application load balancer"
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
  type        = string
  nullable    = false
}

variable "task_memory" {
  description = "Memory"
  type        = string
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
  description = "Desired number of tasks to run for API"
  type        = string
  nullable    = false
}

variable "ecs_svc_min_health_perc" {
  description = "Deployment minimum healthy percentage"
  type        = string
  nullable    = false
}

variable "ecs_svc_max_health_perc" {
  description = "Deployment maximum healthy percentage"
  type        = string
  nullable    = false
}
