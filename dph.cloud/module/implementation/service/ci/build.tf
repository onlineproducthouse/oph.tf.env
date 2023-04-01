#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "build_job" {
  type = object({
    buildspec             = string
    environment_variables = list(object({
      key   = string
      value = string
    }))
  })

  default = {
    buildspec             = ""
    environment_variables = []
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  release_artefacts = {
    for index, branch in var.pipeline.git.branch_names : branch => {
      s3_object_key = "${branch}_release_artefact"
    }
  }
}

module "build_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = var.config_switch.build == false ? {} : {
    for index, branch in var.pipeline.git.branch_names : branch => branch
  }

  client_info = var.client_info

  job = {
    name            = "${each.value}-${var.client_info.project_short_name}-${var.client_info.service_name}-build"
    service_role    = aws_iam_role.ci_role.arn
    is_docker_build = var.ci_job.is_docker_build
    build_timeout   = var.ci_job.build_timeout
    buildspec       = var.build_job.buildspec

    environment_variables = concat(var.build_job.environment_variables, [
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = length(module.registry) <= 0 ? "" : module.registry[0].name },
      { key = "RELEASE_ARTEFACT_STORE", value = module.release_artefact.id },
      { key = "TEST_BRANCH_RELEASE_ARTEFACT_KEY", value = local.release_artefacts[each.value].s3_object_key },
      { key = "RELEASE_MANIFEST", value = local.release_manifest },
      { key = "GIT_BRANCH", value = each.value },
    ])

    vpc = {
      id      = ""
      subnets = []
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
