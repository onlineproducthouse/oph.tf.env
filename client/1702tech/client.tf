#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

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
  name                = local.role_name.shared
  assume_role_policy  = data.aws_iam_policy_document.default.json
  managed_policy_arns = data.terraform_remote_state.iam_policies.outputs.policy.arn_list.operations
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
