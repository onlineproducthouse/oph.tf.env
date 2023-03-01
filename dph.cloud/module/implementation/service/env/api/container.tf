#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cluster" {
  type = object({
    name                      = string
    enable_container_insights = bool
  })

  default = {
    enable_container_insights = false
    name                      = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "cluster" {
  source = "../../../../../module/interface/aws/containers/ecs/cluster"

  client_info = var.client_info
  cluster     = var.cluster
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "cluster" {
  value = module.cluster
}
