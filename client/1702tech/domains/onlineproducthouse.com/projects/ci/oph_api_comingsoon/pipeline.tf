#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  pipelines = [
    {
      environment_name = "local"
      branch_name      = "main"
    },
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
      name            = "build"
      category        = "Build"
      owner           = "AWS"
      provider        = "CodeBuild"
      input_artifacts = [local.artifacts.source]
      version         = "1"

      configuration = {
        ProjectName = module.ci.build_job[each.value.branch_name].name
      }
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
