#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/terraform.tfstate"
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

data "terraform_remote_state" "developer_policies" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/developer/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "operations_policies" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/operations/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  policy_arn_list = {
    developer = [
      data.terraform_remote_state.developer_policies.outputs.policy_arn,
    ]

    operations = [
      data.terraform_remote_state.operations_policies.outputs.operations["compute"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["container"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["database"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["developer_tools"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["monitoring"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["networking"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["security"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["storage"].arn,
    ]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "policy" {
  value = {
    arn_list = {
      developer  = local.policy_arn_list.developer
      operations = local.policy_arn_list.operations
    }

    document = {
      developer       = data.terraform_remote_state.developer_policies.outputs.policy,
      compute         = data.terraform_remote_state.operations_policies.outputs.operations["compute"].policy,
      container       = data.terraform_remote_state.operations_policies.outputs.operations["container"].policy,
      database        = data.terraform_remote_state.operations_policies.outputs.operations["database"].policy,
      developer_tools = data.terraform_remote_state.operations_policies.outputs.operations["developer_tools"].policy,
      monitoring      = data.terraform_remote_state.operations_policies.outputs.operations["monitoring"].policy,
      networking      = data.terraform_remote_state.operations_policies.outputs.operations["networking"].policy,
      security        = data.terraform_remote_state.operations_policies.outputs.operations["security"].policy,
      storage         = data.terraform_remote_state.operations_policies.outputs.operations["storage"].policy,
    }
  }
}
