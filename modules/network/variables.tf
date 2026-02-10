variable "name" {
  description = "The name of the network"
  type        = string
  nullable    = false
}

variable "availability_zone" {
  description = "See: https://aws.amazon.com/about-aws/global-infrastructure/regions_az/"
  type        = list(string)
  nullable    = false
}

variable "vpc_cidr_block" {
  description = "See: https://docs.aws.amazon.com/vpc/latest/userguide/vpc-cidr-blocks.html"
  type        = string
  nullable    = false
}

variable "subnet_cidr_block_private" {
  description = "See: https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html"
  type        = list(string)
  nullable    = false
}

variable "subnet_cidr_block_public" {
  description = "See: https://docs.aws.amazon.com/vpc/latest/userguide/subnet-sizing.html"
  type        = list(string)
  nullable    = false
}

variable "alb_domain_name_alias" {
  description = "Alias DNS record for ALB"
  type        = string
  nullable    = false
}

variable "alb_domain_name_alias_zone_id" {
  description = "Alias DNS record hosted zone id for ALB"
  type        = string
  nullable    = false
}

variable "alb_sg_rule" {
  description = "A list of AWS security group rules to create for the security group created"
  nullable    = false

  type = list(object({
    name        = string
    type        = string
    protocol    = string
    cidr_blocks = list(string)
    port        = number
  }))
}

variable "alb_target_groups" {
  type = list(object({
    id                    = string
    name                  = string
    domain_name           = string
    port                  = number
    acm_certificate_arn   = string
    alb_health_check_path = string
  }))
}
