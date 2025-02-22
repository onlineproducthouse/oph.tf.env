#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "scalegrid_user" {
  source = "../../../../module/interface/aws/security/iam/user"

  user = {
    name       = "scalegrid"
    group_list = []
  }
}

resource "aws_iam_policy" "scalegrid" {
  name        = module.scalegrid_user.name
  path        = "/oph/"
  description = "oph policy for scalegrid"

  policy = data.terraform_remote_state.iam_policies.outputs.policy.document.scalegrid
}

resource "aws_iam_user_policy_attachment" "scalegrid" {
  user       = module.scalegrid_user.name
  policy_arn = aws_iam_policy.scalegrid.arn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
