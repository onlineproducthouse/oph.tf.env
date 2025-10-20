variable "name" {
  description = "A name given to the platform"
  type        = string
  nullable    = false
}

variable "vpc_id" {
  description = "VPC ID where the platform is provisioned"
  type        = string
  nullable    = false
}

variable "subnet_id" {
  description = "A list of subnet IDs where the platform is provisioned"
  type        = list(string)
  nullable    = false
}

variable "cw_log_retention_days" {
  description = "Number of days AWS CloudWatch Logs may be kept for"
  type        = number
  default     = 3
  nullable    = false
}

variable "fs_cors_config_rule" {
  description = "CORS rules for File Service AWS S3 Bucket"
  nullable    = false

  type = list(object({
    allowed_headers = list(string)
    allowed_methods = list(string)
    allowed_origins = list(string)
    expose_headers  = list(string)
    max_age_seconds = number
  }))
}

variable "cluster_sg_rule" {
  description = "A list of AWS security group rules to create for the security group created"
  nullable    = false

  type = list(object({
    name        = string
    type        = string
    protocol    = string
    cidr_blocks = list(string)
    from_port   = number
    to_port     = number
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
