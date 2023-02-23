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

variable "pipeline" {
  type = object({
    name                       = string
    role_arn                   = string
    artifact_store_location_id = string

    source = object({
      git_connection_arn = string
      git_repo_name      = string
      git_branch_name    = string
      output_name        = string
    })

    build = object({
      project_name = string
      output_name  = string
    })

    deployment_targets = object({
      test = string
      prod = string
    })
  })

  default = {
    name                       = "UnknownCodePipeline"
    role_arn                   = ""
    artifact_store_location_id = ""

    source = {
      git_connection_arn = ""
      git_repo_name      = ""
      git_branch_name    = ""
      output_name        = ""
    }

    build = {
      project_name = ""
      output_name  = ""
    }

    deployment_targets = {
      test = ""
      prod = ""
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  channels = {
    is_test = var.pipeline.source.git_branch_name == "test" || var.pipeline.source.git_branch_name == "prod"
    is_prod = var.pipeline.source.git_branch_name == "prod"
  }

  approval = {
    step = {
      name     = "Approval"
      category = "Approval"
      owner    = "AWS"
      provider = "Manual"
      version  = "1"
    }
  }
}

resource "aws_codepipeline" "pipeline" {
  name     = var.pipeline.name
  role_arn = var.pipeline.role_arn

  artifact_store {
    location = var.pipeline.artifact_store_location_id
    type     = "S3"
  }

  stage {
    name = "FetchSourceCode"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = [var.pipeline.source.output_name]

      configuration = {
        ConnectionArn    = var.pipeline.source.git_connection_arn
        FullRepositoryId = var.pipeline.source.git_repo_name
        BranchName       = var.pipeline.source.git_branch_name
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [var.pipeline.source.output_name]
      output_artifacts = [var.pipeline.build.output_name]
      version          = "1"

      configuration = {
        ProjectName = var.pipeline.build.project_name
      }
    }
  }

  dynamic "stage" {
    for_each = local.channels.is_test == true ? local.approval : {}

    content {
      name = "ApproveDeployToTest"

      action {
        name     = stage.value.name
        category = stage.value.category
        owner    = stage.value.owner
        provider = stage.value.provider
        version  = stage.value.version
      }
    }
  }

  dynamic "stage" {
    for_each = local.channels.is_test == true && var.pipeline.deployment_targets.test != "" ? {
      job = var.pipeline.deployment_targets.test
    } : {}

    content {
      name = "DeployToTest"

      action {
        name            = "DeployToTest"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.pipeline.build.output_name]
        version         = "1"

        configuration = {
          ProjectName = stage.value
        }
      }
    }
  }

  dynamic "stage" {
    for_each = local.channels.is_prod == true ? local.approval : {}

    content {
      name = "ApproveDeployToProd"

      action {
        name     = stage.value.name
        category = stage.value.category
        owner    = stage.value.owner
        provider = stage.value.provider
        version  = stage.value.version
      }
    }
  }

  dynamic "stage" {
    for_each = local.channels.is_prod == true && var.pipeline.deployment_targets.prod != "" ? {
      job = var.pipeline.deployment_targets.prod
    } : {}

    content {
      name = "DeployToProd"

      action {
        name            = "DeployToProd"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.pipeline.build.output_name]
        version         = "1"

        configuration = {
          ProjectName = stage.value
        }
      }
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

output "id" {
  value = aws_codepipeline.pipeline.id
}

output "arn" {
  value = aws_codepipeline.pipeline.arn
}
