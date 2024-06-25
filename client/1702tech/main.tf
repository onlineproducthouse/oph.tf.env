#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/terraform.tfstate"
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

// OPH portion: give OPH entities permissions to client account
data "aws_caller_identity" "default" {
  provider = aws.default
}

data "aws_iam_policy_document" "client" {
  provider = aws.client
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.default.account_id]
    }
  }
}

locals {
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

resource "aws_iam_policy" "operations" {
  for_each = {
    for index, document in local.policy_document_list : document.name => document
  }

  provider    = aws.client
  name        = each.value.name
  path        = "/oph/"
  description = "Assume role policy"
  policy      = jsonencode(each.value.policy)
}

resource "aws_iam_role" "client" {
  provider           = aws.client
  name               = "20240625192535"
  assume_role_policy = data.aws_iam_policy_document.client.json
  managed_policy_arns = [
    for index, policy in aws_iam_policy.operations : policy.arn
  ]
}

// Client portion: give client account entities permissions to OPH
data "aws_caller_identity" "client" {
  provider = aws.client
}

data "aws_iam_policy_document" "default" {
  provider = aws.default
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [data.aws_caller_identity.client.account_id]
    }
  }
}

resource "aws_iam_role" "default" {
  provider            = aws.default
  name                = "20240625185750"
  assume_role_policy  = data.aws_iam_policy_document.default.json
  managed_policy_arns = data.terraform_remote_state.iam_policies.outputs.policy.arn_list.operations
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "role_arn" {
  value = {
    for_oph_entities    = aws_iam_role.client.arn
    for_client_entities = aws_iam_role.default.arn
  }
}
