#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "pipeline" {
  type = object({
    git = object({
      connection_arn = string
      repo_name      = string
    })
  })

  default = {
    git = {
      connection_arn = ""
      repo_name      = ""
    }
  }
}

locals {
  pipeline = {
    channels = concat(var.config_switch.deployment_targets, [{
      name = "dev"
      vpc = {
        id                 = ""
        security_group_ids = []
        subnets            = []
      }
    }])
  }
}
#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "pipeline" {
  source = "../../../interface/aws/developer_tools/codepipeline/pipelines"

  for_each = {
    for index, channel in local.pipeline.channels : channel.name => channel
  }

  client_info = var.client_info

  pipeline = {
    name                       = "${var.client_info.project_short_name}-${var.client_info.service_name}-${each.value.name}"
    role_arn                   = aws_iam_role.ci_role.arn
    artifact_store_location_id = module.build_artefact[0].id

    source = {
      git_branch_name    = each.value.name
      git_connection_arn = var.pipeline.git.connection_arn
      git_repo_name      = var.pipeline.git.repo_name
      output_name        = "${var.client_info.project_short_name}-${var.client_info.service_name}-source-output"
    }

    build = {
      project_name = module.build_job[0].name
      output_name  = "${var.client_info.project_short_name}-${var.client_info.service_name}-build-output"
    }

    deployment_targets = {
      test = each.value.name == "test" || each.value.name == "prod" ? module.deploy_job["test"].name : ""
      prod = each.value.name == "prod" ? module.deploy_job["prod"].name : ""
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

