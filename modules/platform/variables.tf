variable "name" {
  description = "A name given to the platform"
  type        = string
  nullable    = false
}

variable "subnet_id" {
  description = "A list of subnet IDs where the platform is provisioned"
  type        = list(string)
  nullable    = false
}

variable "fs_cors_config_rule" {
  description = "CORS rules for File Service AWS S3 Bucket"
  nullable    = false

  type = list(object({
    id              = string
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
}

variable "ec2_image_id" {
  description = "AWS EC2 Image ID for Cluster instances"
  type        = string
  nullable    = false
}

variable "ec2_instance_type" {
  description = "AWS EC2 instance type"
  type        = string
  nullable    = false
}

variable "asg_min" {
  description = "AWS Auto Scaling Group minimum number of instances"
  type        = number
  default     = 0
  nullable    = false
}

variable "asg_max" {
  description = "AWS Auto Scaling Group maximum number of instances"
  type        = number
  default     = 0
  nullable    = false
}

variable "asg_desired" {
  description = "AWS Auto Scaling Group desired number of instances"
  type        = number
  default     = 0
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

variable "log_retention_days" {
  description = "Number of days AWS CloudWatch Logs may be kept for"
  type        = number
  default     = 3
  nullable    = false
}

variable "alb_target_groups" {
  description = "AWS ALB target group ARNs"
  type        = list(string)
  default     = []
}

variable "alb_security_group_id" {
  description = "AWS ALB security group ID"
  type        = string
  nullable    = false
}
