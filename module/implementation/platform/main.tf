#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "platform" {
  type = object({
    run = bool

    name   = string
    region = string

    cloud = object({
      vpc_id                 = string
      private_subnet_id_list = list(string)
    })

    logs = object({
      group = string
    })

    compute = object({
      enable_container_insights = bool
      target_capacity           = number

      instance = object({
        image_id      = string
        instance_type = string
      })

      auto_scaling = object({
        minimum = number
        maximum = number
        desired = number
      })

      security_group_rules = list(object({
        name        = string
        type        = string
        protocol    = string
        cidr_blocks = list(string)
        from_port   = number
        to_port     = number
      }))
    })
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "platform" {
  value = {
    storage      = local.storage_output
    file_service = local.file_service_output
    role         = local.role_output
    logs         = local.logs_output
    compute      = local.compute_output
  }
}
