#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/developer/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}



#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "developer" {
  name        = "developer"
  path        = "/oph/"
  description = "oph policy for developer"

  policy = jsonencode({
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
        Effect = "Allow",
        Action = [
          "codestar-connections:*"
        ],
        Resource = "*"
      },
      {
        Sid = "Stmt1664384493126",
        Action = [
          "ecr:DescribeImages",
          "ecr:DescribeRepositories",
          "ecr:GetAuthorizationToken",
          "ecr:ListImages",
          "ecr:ListTagsForResource"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ecr:*:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Sid = "Stmt1664385491775",
        Action = [
          "s3:GetObject",
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:s3:::*"
      },
      {
        Sid = "Stmt1664385866577",
        Action = [
          "ses:VerifyDomainDkim",
          "ses:VerifyDomainIdentity",
          "ses:VerifyEmailAddress",
          "ses:VerifyEmailIdentity"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ses:*:${data.aws_caller_identity.current.account_id}:*"
      },
      {
        Sid = "Stmt1664386088180",
        Action = [
          "ssm:GetParametersByPath"
        ],
        Effect   = "Allow",
        Resource = "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:*",
        Condition = {
          Bool = {
            Recursive = "true"
          }
        }
      }
    ]
  })
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "developer_policy_arn" {
  value = aws_iam_policy.developer.arn
}
