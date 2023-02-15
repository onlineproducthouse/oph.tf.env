#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "registry" {
  description = "AWS ECR docker image repo"

  type = object({
    name         = string
    service_name = string
  })

  default = {
    name         = ""
    service_name = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "registry" {
  source = "../../../../module/interface/aws/containers/ecr"

  count = var.config_switch.registry == true ? 1 : 0

  name         = var.registry.name
  service_name = var.registry.service_name

  owner            = var.owner
  environment_name = var.environment_name
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "registry" {
  value = module.registry[0]
}
