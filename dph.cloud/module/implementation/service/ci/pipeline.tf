#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "pipeline" {
  type = object({
    artifacts = object({
      source  = string
      build   = string
      release = string
    })

    git = object({
      connection_arn = string
      repo_name      = string
      branch_names   = list(string)
    })
  })

  default = {
    artifacts = {
      source  = ""
      build   = ""
      release = ""
    }

    git = {
      connection_arn = ""
      repo_name      = ""
      branch_names   = []
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codepipeline" "build" {
  for_each = {
    for index, branch in var.pipeline.git.branch_names : branch => branch
  }

  name     = "build-${var.client_info.project_short_name}-${var.client_info.service_name}-${each.value}"
  role_arn = aws_iam_role.ci_role.arn

  artifact_store {
    location = module.build_artefact[0].id
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
      output_artifacts = [var.pipeline.artifacts.source]

      configuration = {
        ConnectionArn    = var.pipeline.git.connection_arn
        FullRepositoryId = var.pipeline.git.repo_name
        BranchName       = each.value
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
      input_artifacts  = [var.pipeline.artifacts.source]
      output_artifacts = [var.pipeline.artifacts.build]
      version          = "1"

      configuration = {
        ProjectName = module.build_job[each.value].name
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

locals {
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

resource "aws_codepipeline" "release" {
  for_each = {
    for index, target in var.deploy_job.deployment_targets : target.name => target
  }

  name     = "release-${var.client_info.project_short_name}-${var.client_info.service_name}-${each.value.name}"
  role_arn = aws_iam_role.ci_role.arn

  artifact_store {
    location = module.release_artefact.id
    type     = "S3"
  }

  stage {
    name = "FetchSourceCode"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = [var.pipeline.artifacts.release]

      configuration = {
        S3Bucket    = module.release_artefact.id
        S3ObjectKey = local.release_artefacts[each.value.name].s3_object_key
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.name == "test" || each.value.name == "prod" ? local.approval : {}

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
    for_each = each.value.name == "test" || each.value.name == "prod" ? each.value : {}

    content {
      name = "DeployToTest"

      action {
        name            = "DeployToTest"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.pipeline.artifacts.release]
        version         = "1"

        configuration = {
          ProjectName = module.deploy_job["test"].name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.name == "prod" ? local.approval : {}

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
    for_each = each.value.name == "prod" ? each.value : {}

    content {
      name = "DeployToProd"

      action {
        name            = "DeployToProd"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.pipeline.artifacts.release]
        version         = "1"

        configuration = {
          ProjectName = module.deploy_job["prod"].name
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
