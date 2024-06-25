data "aws_iam_policy_document" "developer" {
  
}

locals {
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
        Resource = "*"
      },
      {
        Sid = "Stmt1664385491775",
        Action = [
          "s3:GetObject",
          "s3:ListAllMyBuckets",
          "s3:ListBucket"
        ],
        Effect   = "Allow",
        Resource = "*"
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
        Resource = "*"
      },
      {
        Sid = "Stmt1664386088180",
        Action = [
          "ssm:GetParametersByPath"
        ],
        Effect   = "Allow",
        Resource = "*",
        Condition = {
          Bool = {
            Recursive = "true"
          }
        }
      }
    ]
  })
}
