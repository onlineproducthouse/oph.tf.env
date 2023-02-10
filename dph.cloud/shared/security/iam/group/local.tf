locals {
  policies = {
    developer_policies = [
      "${data.terraform_remote_state.developer_policies.outputs.developer_policy_arn}",
    ]

    operations_policies = [
      "${data.terraform_remote_state.operations_policies.outputs.business_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.compute_autoscaling_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.compute_ec2_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.compute_elasticloadbalancing_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.container_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.database_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.monitoring_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.networking_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.security_policy_arn}",
      "${data.terraform_remote_state.operations_policies.outputs.storage_policy_arn}",
    ]
  }
}
