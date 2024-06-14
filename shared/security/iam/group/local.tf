locals {
  policies = {
    developer_policies = [
      data.terraform_remote_state.developer_policies.outputs.developer_policy_arn,
    ]

    operations_policies = [
      data.terraform_remote_state.operations_policies.outputs.operations["business"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["compute_ec2"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["compute_autoscaling"].arn,
      data.terraform_remote_state.operations_policies.outputs.operations["compute_elasticloadbalancing"].arn,
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

locals {
  groups = [
    { name = "developer", policies = local.policies.developer_policies },
    { name = "operations", policies = local.policies.operations_policies },
  ]
}