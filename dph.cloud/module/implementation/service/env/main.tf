#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

variable "env" {
  type = object({
    network = object({
      vpc_cidr_block  = string
      dest_cidr_block = string

      subnets = object({
        private = object({
          cidr_block         = list(string)
          availibility_zones = list(string)
        })

        public = object({
          cidr_block         = list(string)
          availibility_zones = list(string)
        })
      })
    })
  })

  default = {
    network = {
      vpc_cidr_block  = ""
      dest_cidr_block = "0.0.0.0/0"

      subnets = {
        private = {
          availibility_zones = []
          cidr_block         = []
        }

        public = {
          availibility_zones = []
          cidr_block         = []
        }
      }
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "network" {
  source = "./network"

  count = var.env.network.vpc_cidr_block == "" ? 0 : 1

  client_info     = var.client_info
  vpc_cidr_block  = var.env.network.vpc_cidr_block
  dest_cidr_block = var.env.network.dest_cidr_block
  subnets         = var.env.network.subnets
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "network" {
  value = module.network[0].network
}
