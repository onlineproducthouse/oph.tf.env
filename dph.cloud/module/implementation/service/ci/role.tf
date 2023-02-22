#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_policy" "ci_policy" {
  name        = "ci-policy-${var.client_info.project_short_name}-${var.client_info.service_name}"
  path        = "/${var.client_info.project_short_name}/"
  description = "${var.client_info.project_name} policy for ci"

  policy = jsonencode(local.policy)
}

resource "aws_iam_role" "ci_role" {
  name = "ci-role-${var.client_info.project_short_name}-${var.client_info.service_name}"
  path = "/system/ci/"

  force_detach_policies = true
  managed_policy_arns   = [aws_iam_policy.ci_policy.arn]

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal : {
          Service : "codebuild.amazonaws.com"
        },
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal : {
          Service : "codepipeline.amazonaws.com"
        },
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal : {
          Service : "ecs.amazonaws.com"
        },
      },
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        },
      },
    ]
  })

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

locals {
  policy = {
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "codebuild:*"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "codepipeline:*"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = "codestar-connections:UseConnection",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:CreateNetworkInterfacePermission"
        ],
        Resource = "*",
        Condition = {
          StringEquals = {
            "ec2:AuthorizedService" = "codebuild.amazonaws.com"
          }
        }
      },
      {
        Sid = "Stmt1664394430713",
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:ListDistributions"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664394584942",
        Action = [
          "logs:CreateLogDelivery",
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:DeleteLogDelivery",
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:DescribeDestinations",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams",
          "logs:PutLogEvents",
          "logs:UpdateLogDelivery"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664395152062",
        Action = [
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:CreateNetworkInterface",
          "ec2:Describe*",
          "ec2:DeleteNetworkInterface",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664395350771",
        Action = [
          "ecr:BatchGetImage",
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:ListTagsForResource",
          "ecr:PutImage",
          "ecr:StartImageScan"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664395505054",
        Action = [
          "ecs:CreateCapacityProvider",
          "ecs:CreateService",
          "ecs:CreateTaskSet",
          "ecs:DeleteCapacityProvider",
          "ecs:DeregisterContainerInstance",
          "ecs:DeregisterTaskDefinition",
          "ecs:DescribeCapacityProviders",
          "ecs:DescribeClusters",
          "ecs:DescribeContainerInstances",
          "ecs:DescribeServices",
          "ecs:DescribeTaskDefinition",
          "ecs:DescribeTaskSets",
          "ecs:DescribeTasks",
          "ecs:ListAttributes",
          "ecs:ListClusters",
          "ecs:ListContainerInstances",
          "ecs:ListServices",
          "ecs:ListTaskDefinitionFamilies",
          "ecs:ListTaskDefinitions",
          "ecs:ListTasks",
          "ecs:PutAttributes",
          "ecs:RegisterTaskDefinition",
          "ecs:RunTask",
          "ecs:StartTask",
          "ecs:StopTask",
          "ecs:UpdateContainerInstancesState",
          "ecs:UpdateService",
          "ecs:UpdateTaskSet"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664395646044",
        Action = [
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:DeregisterInstancesFromLoadBalancer",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RegisterInstancesWithLoadBalancer"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664395896091",
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateRole",
          "iam:CreatePolicy",
          "iam:DetachRolePolicy",
          "iam:GetPolicy",
          "iam:GetRole",
          "iam:GetRolePolicy",
          "iam:ListAttachedRolePolicies",
          "iam:ListPolicies",
          "iam:ListRolePolicies",
          "iam:ListRoles",
          "iam:PutRolePolicy",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664396122539",
        Action = [
          "ssm:GetParametersByPath"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Sid = "Stmt1664391913340",
        Action = [
          "s3:GetObject",
          "s3:PutObject",
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "iam:CreateServiceLinkedRole",
          "iam:UpdateRoleDescription"
        ],
        Resource = "arn:aws:iam::*:role/aws-service-role/ecs.amazonaws.com/AWSServiceRoleForECS*",
        Condition = {
          StringLike = {
            "iam:AWSServiceName" = "ecs.amazonaws.com"
          }
        }
      },
      {
        Sid    = "CodeStarCF",
        Effect = "Allow",
        Action = [
          "cloudformation:DescribeStack*",
          "cloudformation:GetTemplateSummary"
        ],
        Resource = [
          "arn:aws:cloudformation:*:*:stack/awscodestar-*"
        ]
      }
    ]
  }
}
