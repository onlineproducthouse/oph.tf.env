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

variable "content" {
  type = object({
    db_cert_source_path = string
  })
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

module "content" {
  source      = "./content"
  client_info = var.client_info
  content     = var.content
}

module "api" {
  source      = "./api"
  client_info = var.client_info
  cluster = {
    enable_container_insights = false
    name                      = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}-cluster"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "network" {
  value = var.env.network.vpc_cidr_block != "" ? module.network[0].network : {
    vpc_id = ""
    eip    = []
    subnet_id_list = {
      private = []
      public  = []
    }
  }
}

output "content" {
  value = module.content
}

output "api" {
  value = module.api
}
