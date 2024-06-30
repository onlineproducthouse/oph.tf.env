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

data "aws_iam_policy_document" "client_to_default" {
  provider = aws.client
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.default.arn]
  }
}

resource "aws_iam_policy" "client_to_default" {
  provider = aws.client
  name     = local.role_name.shared
  path     = "/"
  policy   = data.aws_iam_policy_document.client_to_default.json
}

resource "aws_iam_role_policy_attachment" "client_to_default" {
  provider   = aws.client
  role       = aws_iam_role.client.name
  policy_arn = aws_iam_policy.client_to_default.arn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
