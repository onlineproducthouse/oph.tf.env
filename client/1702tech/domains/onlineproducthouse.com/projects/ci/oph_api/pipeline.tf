#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

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

  pipelines = [
    {
      environment_name = "local"
      branch_name      = "dev"
    },
    {
      environment_name = "test"
      branch_name      = "qa"
    },
    {
      environment_name = "qa"
      branch_name      = "qa"
    },
    # {
    #   environment_name = "prod"
    #   branch_name      = "main"
    # },
  ]
}

resource "aws_codepipeline" "pipelines" {
  for_each = {
    for i, v in local.pipelines : v.environment_name => v
  }

  name     = "${local.name}-${each.value.environment_name}"
  role_arn = module.ci.role.arn

  artifact_store {
    location = module.ci.build_artefact[each.value.branch_name]
    type     = "S3"
  }

  stage {
    name = "source"

    action {
      name             = "source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = [local.artifacts.source]

      configuration = {
        ConnectionArn    = local.git.connection_arn
        FullRepositoryId = local.git.repo_name
        BranchName       = each.value.branch_name
      }
    }
  }

  stage {
    name = "build"

    action {
      name             = "build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = [local.artifacts.source]
      output_artifacts = [local.artifacts.build]
      version          = "1"

      configuration = {
        ProjectName = module.ci.build_job[each.value.branch_name].name
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.environment_name == "test" ? local.approval : {}

    content {
      name = "approve_deploy_test"

      action {
        name     = "approve_deploy_test"
        category = stage.value.category
        owner    = stage.value.owner
        provider = stage.value.provider
        version  = stage.value.version
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.environment_name == "test" ? local.approval : {}

    content {
      name = "deploy_test"

      action {
        name            = "deploy_test"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [local.artifacts.build]
        version         = "1"

        configuration = {
          ProjectName = module.ci.release_job.test.name
        }
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.environment_name == "qa" || each.value.environment_name == "prod" ? local.approval : {}

    content {
      name = "approve_deploy_qa"

      action {
        name     = "approve_deploy_qa"
        category = stage.value.category
        owner    = stage.value.owner
        provider = stage.value.provider
        version  = stage.value.version
      }
    }
  }

  dynamic "stage" {
    for_each = each.value.environment_name == "qa" || each.value.environment_name == "prod" ? local.approval : {}

    content {
      name = "deploy_qa"

      action {
        name            = "deploy_qa"
        category        = "Build"
        owner           = "AWS"
        provider        = "CodeBuild"
        input_artifacts = [local.artifacts.build]
        version         = "1"

        configuration = {
          ProjectName = module.ci.release_job.qa.name
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
