#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "username" {
  type        = string
  default     = ""
  description = "AWS IAM user name"
}

variable "user_group_list" {
  type        = list(string)
  default     = []
  description = "The groups this user belongs to"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_user" "user" {
  name = var.username
  path = "/users/"
}

resource "aws_iam_user_group_membership" "user_groups" {
  user   = aws_iam_user.user.name
  groups = var.user_group_list
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
