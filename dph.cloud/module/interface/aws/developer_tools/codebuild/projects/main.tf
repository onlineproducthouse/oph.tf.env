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
      id      = string
      subnets = list(string)
    })
  })

  default = {
    name                  = "UnknownCodeBuild"
    is_docker_build       = false
    service_role          = ""
    build_timeout         = "10"
    buildspec             = ""
    environment_variables = []
    vpc = {
      id      = ""
      subnets = []
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "security_group" {
  count = var.job.vpc.id == "" ? 0 : 1

  name   = "${var.job.name}-sg"
  vpc_id = var.job.vpc.id

  lifecycle {
    create_before_destroy = false
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_security_group_rule" "rule" {
  count = var.job.vpc.id == "" ? 0 : 1

  security_group_id = aws_security_group.security_group[0].id

  type        = "egress"
  protocol    = "-1"
  cidr_blocks = ["0.0.0.0/0"]
  from_port   = 0
  to_port     = 0
}

resource "aws_codebuild_project" "job" {
  name           = var.job.name
  service_role   = var.job.service_role
  build_timeout  = var.job.build_timeout
  queued_timeout = "60"

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
    for_each = var.job.vpc.id == "" ? [] : [{
      vpc_id             = var.job.vpc.id
      subnets            = var.job.vpc.subnets
      security_group_ids = var.job.vpc.id == "" ? [] : [aws_security_group.security_group[0].id]
    }]

    content {
      vpc_id             = vpc_config.value.vpc_id
      subnets            = vpc_config.value.subnets
      security_group_ids = vpc_config.value.security_group_ids
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
