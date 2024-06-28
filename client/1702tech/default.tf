#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

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
      identifiers = [for i, u in data.terraform_remote_state.iam_users.outputs.users : u.arn]
    }
  }
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
  name               = local.role_name.shared
  assume_role_policy = data.aws_iam_policy_document.client.json
  managed_policy_arns = [
    for index, policy in aws_iam_policy.operations : policy.arn
  ]
}

data "aws_iam_policy_document" "default_to_client" {
  provider = aws.default
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.client.arn]
  }
}

resource "aws_iam_policy" "default_to_client" {
  provider = aws.default
  name     = local.role_name.shared
  path     = "/"
  policy   = data.aws_iam_policy_document.default_to_client.json
}

resource "aws_iam_user_policy_attachment" "default_to_client" {
  provider = aws.default
  for_each = {
    for i, u in data.terraform_remote_state.iam_users.outputs.users : u.name => u
  }

  user       = each.value.name
  policy_arn = aws_iam_policy.default_to_client.arn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
