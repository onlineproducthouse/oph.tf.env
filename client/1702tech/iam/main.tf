#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/iam/terraform.tfstate"
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

data "terraform_remote_state" "iam_groups" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/group/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "iam_users" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/user/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  role_name = {
    shared = "202406251925"
  }

  policy_document_list = [
    { name = "compute", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.compute },
    { name = "container", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.container },
    { name = "database", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.database },
    { name = "developer_tools", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.developer_tools },
    { name = "monitoring", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.monitoring },
    { name = "networking", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.networking },
    { name = "security", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.security },
    { name = "storage", policy = data.terraform_remote_state.iam_policies.outputs.policy.document.storage },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "role_arn" {
  value = {
    for_oph_entities = aws_iam_role.client.arn
  }
}
