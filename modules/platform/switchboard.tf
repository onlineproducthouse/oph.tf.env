#region Variables

variable "sb_cloudwatch" {
  description = "Switchboard for whether a cloudwatch log group must be provisioned"
  type        = bool
  default     = false
  nullable    = false
}

variable "sb_iam" {
  description = "Switchboard for whether IAM resources must be provisioned"
  type        = bool
  default     = false
  nullable    = false
}

variable "sb_compute" {
  description = "Switchboard for whether compute resources must be provisioned"
  type        = bool
  default     = false
  nullable    = false
}

#endregion

#region Locals

locals {
  switchboard = {
    cw      = var.sb_cloudwatch || var.sb_compute
    iam     = var.sb_iam || var.sb_compute
    compute = var.sb_compute
  }
}

#endregion
