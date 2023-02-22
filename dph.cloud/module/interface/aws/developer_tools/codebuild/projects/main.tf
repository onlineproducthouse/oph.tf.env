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

variable "build_job" {
  type = object({
    name            = string
    service_role    = string
    build_timeout   = string
    buildspec       = string
    is_docker_build = bool
    environment_variables = list(object({
      key   = string
      value = string
    }))
    run_in_subnet      = bool
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })

  default = {
    build_timeout         = "10"
    buildspec             = ""
    environment_variables = []
    is_docker_build       = false
    name                  = "UnknownCodeBuild"
    run_in_subnet         = false
    security_group_ids    = []
    service_role          = ""
    subnets               = []
    vpc_id                = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codebuild_project" "build_job" {
  name           = var.build_job.name
  service_role   = var.build_job.service_role
  build_timeout  = var.build_job.build_timeout
  queued_timeout = "5"

  artifacts {
    type     = "CODEPIPELINE"
    location = "CODEPIPELINE"
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = var.build_job.buildspec
  }

  environment {
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:6.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"

    privileged_mode = var.build_job.is_docker_build

    dynamic "environment_variable" {
      for_each = var.build_job.environment_variables

      content {
        name  = environment_variable.value.key
        value = environment_variable.value.value
      }
    }
  }

  dynamic "vpc_config" {
    for_each = var.build_job.run_in_subnet == true ? [{
      vpc_id             = var.build_job.vpc_id
      subnets            = var.build_job.subnets
      security_group_ids = var.build_job.security_group_ids
    }] : []

    content {
      vpc_id             = var.build_job.vpc_id
      subnets            = var.build_job.subnets
      security_group_ids = var.build_job.security_group_ids
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
  value = aws_codebuild_project.build_job.arn
}

output "name" {
  value = aws_codebuild_project.build_job.name
}
