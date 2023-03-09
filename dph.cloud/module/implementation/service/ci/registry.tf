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

data "aws_caller_identity" "current" {}

locals {
  registry = {
    base_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com"
  }
}

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

# output "registry" {
#   value = module.registry[0]
# }
