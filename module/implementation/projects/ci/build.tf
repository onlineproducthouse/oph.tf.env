#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  build_artefacts_s3_object_key = {
    for i, build_job in var.ci.jobs.build : build_job.branch_name => "${build_job.branch_name}_build_artefact"
  }
}

module "build_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = {
    for i, build_job in var.ci.jobs.build : build_job.branch_name => build_job
  }

  job = {
    name            = "${var.ci.name}-${each.value.branch_name}-build"
    service_role    = local.role_output.arn
    is_docker_build = var.ci.is_container
    build_timeout   = each.value.timeout
    buildspec       = each.value.buildspec

    environment_variables = concat(each.value.environment_variables, [
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry_output.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = local.registry_output.name },
      { key = "BUILD_ARTEFACT_STORE", value = local.build_artefact_output[each.value.branch_name] },
      { key = "BUILD_ARTEFACT_KEY", value = local.build_artefacts_s3_object_key[each.value.branch_name] },
      { key = "RELEASE_MANIFEST", value = local.release_manifest },
      { key = "GIT_BRANCH", value = each.value.branch_name },
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
