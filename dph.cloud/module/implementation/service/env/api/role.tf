#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_policy" "api" {
  name        = "${var.api.name}-policy"
  path        = "/system/"
  description = "${var.client_info.project_name} policy for launch configuration"

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

resource "aws_iam_role" "api" {
  name = "${var.api.name}-role"
  path = "/system/"

  force_detach_policies = true
  managed_policy_arns   = [aws_iam_policy.api.arn]
  permissions_boundary  = ""

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "DPHEC2AssumedRole"
      },
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "DPHECSTASKAssumedRole"
      },
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ecs.amazonaws.com"
        },
        Effect : "Allow",
        Sid : "DPHECSAssumedRole"
      }
    ]
  })

  lifecycle {
    ignore_changes = [managed_policy_arns]
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_iam_instance_profile" "api" {
  name = "ecsInstanceRole"
  path = "/system/"
  role = aws_iam_role.api.name
}

resource "aws_iam_role_policy_attachment" "container_service_attach" {
  role       = aws_iam_role.api.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
