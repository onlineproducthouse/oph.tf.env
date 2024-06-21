#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_policy" "platform" {
  name        = "${var.platform.name}-policy"
  path        = "/system/"
  description = "${var.platform.name} policy for launch template"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid = "Stmt1664390969881",
        Action = [
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetRulePriorities",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:SetWebAcl"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect : "Allow",
        Action : [
          "s3:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ecr:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ec2:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ecs:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "iam:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ssm:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "autoscaling:CreateOrUpdateTags"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ses:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "logs:*"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role" "platform" {
  name                 = "${var.platform.name}-role"
  path                 = "/system/"
  permissions_boundary = ""

  force_detach_policies = true
  managed_policy_arns   = [aws_iam_policy.platform.arn]

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "OPHEC2AssumedRole"
      },
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "OPHECSTASKAssumedRole"
      },
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "OPHECSAssumedRole"
      }
    ]
  })

  lifecycle {
    ignore_changes = [managed_policy_arns]
  }
}

resource "aws_iam_instance_profile" "platform" {
  name = "${var.platform.name}-ecs-role"
  path = "/system/"
  role = aws_iam_role.platform.name
}

resource "aws_iam_role_policy_attachment" "container_service_attach" {
  role       = aws_iam_role.platform.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  role_output = {
    name = aws_iam_role.platform.name
    id   = aws_iam_role.platform.id
    arn  = aws_iam_role.platform.arn

    instance = {
      id  = aws_iam_instance_profile.platform.id
      arn = aws_iam_instance_profile.platform.arn
    }
  }
}
