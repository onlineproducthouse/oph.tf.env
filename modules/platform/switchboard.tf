#region Variables

variable "sb_compute" {
  description = "Switchboard for whether compute resources must be provisioned"
  type        = bool
  default     = false
  nullable    = false
}

variable "sb_storage" {
  description = "Switchboard for whether storage resources must be provisioned"
  type        = bool
  default     = false
  nullable    = false
}

#endregion

#region Locals

locals {
  switchboard = {
    compute = var.sb_compute
    storage = var.sb_storage
  }
}

#endregion
