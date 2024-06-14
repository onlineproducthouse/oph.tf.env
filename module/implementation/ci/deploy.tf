#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "deploy_job" {
  source = "../../interface/aws/developer_tools/codebuild/projects"

  for_each = {
    for i, target in var.ci.deploy_job.deployment_targets : target.name => target
  }

  job = {
    name            = "${var.ci.name}-${each.value.name}-deploy"
    service_role    = local.role_output.arn
    is_docker_build = var.ci.is_docker_build
    build_timeout   = var.ci.build_timeout
    buildspec       = var.ci.deploy_job.buildspec

    environment_variables = concat(var.ci.deploy_job.environment_variables, [
      { key = "ENVIRONMENT_NAME", value = each.value.name },
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry_output.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = local.registry_output.name },
      { key = "RELEASE_MANIFEST", value = local.release_manifest },
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
