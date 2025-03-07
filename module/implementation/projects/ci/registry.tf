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

  count = var.ci.is_container == true ? 1 : 0

  ecr = {
    name         = var.ci.name
    force_delete = true
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  registry_output = {
    name     = var.ci.is_container == true ? module.registry.0.name : ""
    base_url = var.ci.is_container == true ? local.registry.base_url : ""
  }
}
