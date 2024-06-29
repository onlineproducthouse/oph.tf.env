#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cloud" {
  type = object({
    run = bool

    name   = string
    region = string

    network = object({
      availibility_zones = list(string)

      cidr_blocks = object({
        vpc    = string
        public = string

        subnets = object({
          private = list(string)
          public  = list(string)
        })
      })
    })

    load_balancer = object({
      security_group_rules = list(object({
        name        = string
        type        = string
        protocol    = string
        cidr_blocks = list(string)
        port        = number
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

output "cloud" {
  value = {
    run           = var.cloud.run
    network       = local.network_output
    load_balancer = local.load_balancer_output
    storage       = local.storage_output
  }
}
