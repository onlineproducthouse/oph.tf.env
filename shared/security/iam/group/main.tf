#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/group/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "iam_policies" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  groups = [
    { name = "developer", policies = data.terraform_remote_state.iam_policies.outputs.policies.developer },
    { name = "operations", policies = data.terraform_remote_state.iam_policies.outputs.policies.operations },
  ]
}

module "groups" {
  source = "../../../../module/interface/aws/security/iam/group"

  for_each = {
    for index, group in local.groups : group.name => group
  }

  group = {
    name                             = each.value.name
    iam_group_attach_policy_arn_list = each.value.policies
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "groups" {
  value = {
    for index, group in local.groups : group.name => {
      name = module.groups[group.name].name
    }
  }
}
