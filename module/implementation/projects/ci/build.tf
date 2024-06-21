#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  release_artefacts = {
    for index, branch in var.ci.pipeline.git.branch_names : branch => {
      s3_object_key = "${branch}_release_artefact"
    }
  }
}

module "build_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = var.ci.run == true ? {
    for index, branch in var.ci.pipeline.git.branch_names : branch => branch
  } : {}

  job = {
    name            = "${var.ci.name}-${each.value}-build"
    service_role    = local.role_output.arn
    is_docker_build = var.ci.is_docker_build
    build_timeout   = var.ci.build_timeout
    buildspec       = var.ci.build_job.buildspec

    environment_variables = concat(var.ci.build_job.environment_variables, [
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry_output.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = local.registry_output.name },
      { key = "RELEASE_ARTEFACT_STORE", value = local.release_artefact_output.id },
      { key = "QA_BRANCH_RELEASE_ARTEFACT_KEY", value = local.release_artefacts[each.value].s3_object_key },
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

locals {
  build_job_output = module.build_job
}
