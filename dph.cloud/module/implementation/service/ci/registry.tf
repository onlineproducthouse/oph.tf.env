#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################


#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "registry" {
  source      = "../../../../module/interface/aws/containers/ecr"
  count       = var.config_switch.registry == true ? 1 : 0
  client_info = var.client_info
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "registry" {
  value = module.registry[0]
}
