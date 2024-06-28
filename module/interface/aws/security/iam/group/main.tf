#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "group" {
  type = object({
    name                             = string
    iam_group_attach_policy_arn_list = list(string)
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_group" "group" {
  name = var.group.name
  path = "/groups/"
}

resource "aws_iam_group_policy_attachment" "group" {
  count = length(var.group.iam_group_attach_policy_arn_list)

  group      = aws_iam_group.group.name
  policy_arn = element(var.group.iam_group_attach_policy_arn_list, count.index)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "name" {
  value = aws_iam_group.group.name
}

output "arn" {
  value = aws_iam_group.group.arn
}
