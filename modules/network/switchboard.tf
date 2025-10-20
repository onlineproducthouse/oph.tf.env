#region Variables

variable "sb_eip" {
  description = "Create Elastic IPs for public subnets. Elastic IPs are required for creating a NAT Gateway. If the NAT Gateway value is set to true, this will be true as well."
  default     = false
  type        = bool
}

variable "sb_nat_gateway" {
  description = "Create NAT Gateway in public subnets. Requires Elastic IPs are provisioned."
  default     = false
  type        = bool
}

variable "sb_alb" {
  description = "Create Application Load Balancer."
  default     = false
  type        = bool
}

#endregion

#region Locals

locals {
  switchboard = {
    eip = var.sb_eip || var.sb_nat_gateway ? var.subnet_cidr_block_public : []
    alb = var.sb_alb
  }
}

#endregion
