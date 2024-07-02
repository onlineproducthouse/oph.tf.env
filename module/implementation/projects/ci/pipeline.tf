#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_codepipeline" "build" {
  for_each = {
    for index, branch in var.ci.pipeline.git.branch_names : branch => branch
  }

  name     = "${var.ci.name}-${each.value}-build"
  role_arn = local.role_output.arn

  artifact_store {
    location = local.build_artefact_output.id
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
      output_artifacts = [var.ci.pipeline.artifacts.source]

      configuration = {
        ConnectionArn    = var.ci.pipeline.git.connection_arn
        FullRepositoryId = var.ci.pipeline.git.repo_name
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
      input_artifacts  = [var.ci.pipeline.artifacts.source]
      output_artifacts = [var.ci.pipeline.artifacts.build]
      version          = "1"

      configuration = {
        ProjectName = local.build_job_output[each.value].name
      }
    }
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
    for index, target in var.ci.deploy_job.deployment_targets : target.name => target
  }

  name     = "${var.ci.name}-${each.value.name}-release"
  role_arn = local.role_output.arn

  artifact_store {
    location = local.release_artefact_output.id
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
      output_artifacts = [var.ci.pipeline.artifacts.release]

      configuration = {
        S3Bucket    = local.release_artefact_output.id
        S3ObjectKey = "${local.release_artefacts[each.value.name].s3_object_key}.zip"
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.name == "qa" || each.value.name == "prod" ? local.approval : {}

    content {
      name = "DeployToQa"

      action {
        name            = "DeployToQa"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.ci.pipeline.artifacts.release]
        version         = "1"

        configuration = {
          ProjectName = local.deploy_job_output[each.value.name].name
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
    for_each = each.value.name == "prod" ? local.approval : {}

    content {
      name = "DeployToProd"

      action {
        name            = "DeployToProd"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [var.ci.pipeline.artifacts.release]
        version         = "1"

        configuration = {
          ProjectName = local.deploy_job_output[each.value.name].name
        }
      }
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  pipeline_output = concat(
    [for v in aws_codepipeline.build : { name = v.name, arn = v.arn }],
    [for v in aws_codepipeline.release : { name = v.name, arn = v.arn }],
  )
}
