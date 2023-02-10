#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "group_name" {
  type    = string
  default = "UnknownIAMGroup"
}

variable "iam_group_attach_policy_arn_list" {
  type    = list(string)
  default = []
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_group" "group" {
  name = var.group_name
  path = "/groups/"
}

resource "aws_iam_group_policy_attachment" "group_attached_policies" {
  count = length(var.iam_group_attach_policy_arn_list)

  group      = aws_iam_group.group.name
  policy_arn = element(var.iam_group_attach_policy_arn_list, count.index)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "name" {
  value = aws_iam_group.group.name
}
