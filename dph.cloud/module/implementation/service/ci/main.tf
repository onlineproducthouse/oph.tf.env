#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}


variable "config_switch" {
  description = "Config switch allows the selection of which resources to provision"

  type = object({
    registry           = bool
    build_artefact     = bool
    build              = bool
    deployment_targets = list(string) // ["test", "prod"]
  })

  default = {
    registry           = false
    build_artefact     = false
    build              = false
    deployment_targets = []
  }
}

variable "ci_job" {
  type = object({
    service_role    = string
    build_timeout   = string
    is_docker_build = bool
  })

  default = {
    service_role    = ""
    build_timeout   = "10"
    is_docker_build = false
  }
}

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
