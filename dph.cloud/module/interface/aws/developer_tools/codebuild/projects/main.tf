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

variable "job" {
  type = object({
    name            = string
    is_docker_build = bool
    service_role    = string
    build_timeout   = string
    buildspec       = string

    environment_variables = list(object({
      key   = string
      value = string
    }))

    vpc = object({
      id                 = string
      subnets            = list(string)
      security_group_ids = list(string)
    })
  })

  default = {
    build_timeout         = "10"
    buildspec             = ""
    environment_variables = []
    is_docker_build       = false
    name                  = "UnknownCodeBuild"
    service_role          = ""
    vpc = {
      id                 = ""
      security_group_ids = []
      subnets            = []
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codebuild_project" "job" {
  name           = var.job.name
  service_role   = var.job.service_role
  build_timeout  = var.job.build_timeout
  queued_timeout = var.job.build_timeout

  artifacts {
    type     = "CODEPIPELINE"
    location = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.job.buildspec
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = var.job.is_docker_build

    dynamic "environment_variable" {
      for_each = var.job.environment_variables

      content {
        name  = environment_variable.value.key
        value = environment_variable.value.value
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.job.vpc.id == "" ? [] : [var.job.vpc]

    content {
      vpc_id             = each.value.id
      subnets            = each.value.subnets
      security_group_ids = each.value.security_group_ids
    }
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "arn" {
  value = aws_codebuild_project.job.arn
}

output "name" {
  value = aws_codebuild_project.job.name
}
