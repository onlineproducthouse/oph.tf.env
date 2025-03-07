#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "release_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = {
    for i, release_job in var.ci.jobs.release : release_job.name => release_job
  }

  job = {
    name            = "${var.ci.name}-${each.value.name}-release"
    service_role    = local.role_output.arn
    is_docker_build = var.ci.is_container
    build_timeout   = each.value.timeout
    buildspec       = each.value.buildspec

    environment_variables = concat(each.value.environment_variables, [
      { key = "ENVIRONMENT_NAME", value = each.value.environment_name },
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry_output.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = local.registry_output.name },
      { key = "RELEASE_MANIFEST", value = local.release_manifest },
      { key = "GIT_BRANCH", value = each.value.branch_name },
    ])

    vpc = {
      id      = each.value.vpc.id
      subnets = each.value.vpc.subnets
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  release_job_output = module.release_job
}
