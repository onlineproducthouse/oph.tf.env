#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "user" {
  type = object({
    name       = string
    group_list = list(string)
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_user" "user" {
  name = var.user.name
  path = "/users/"
}

resource "aws_iam_user_group_membership" "user" {
  user   = aws_iam_user.user.name
  groups = var.user.group_list
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "name" {
  value = aws_iam_user.user.name
}

output "arn" {
  value = aws_iam_user.user.arn
}
