#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

locals {
  registry = {
    base_url = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.ci.region}.amazonaws.com"
  }
}

module "registry" {
  source = "../../../module/interface/aws/containers/ecr"

  count = var.ci.run == true ? 1 : 0

  ecr = {
    name = "${var.ci.name}-registry"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  registry_output = {
    name     = module.registry[0].name
    base_url = local.registry.base_url
  }
}
