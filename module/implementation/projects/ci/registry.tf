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
  source = "../../../interface/aws/containers/ecr"

  ecr = {
    name         = "${var.ci.name}-registry"
    force_delete = false
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  registry_output = {
    name     = module.registry.name
    base_url = local.registry.base_url
  }
}
