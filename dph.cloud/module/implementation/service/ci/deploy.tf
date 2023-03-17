#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "deploy_job" {
  type = object({
    buildspec = string

    environment_variables = list(object({
      key   = string
      value = string
    }))

    deployment_targets = list(object({
      name = string // "test", "prod"
      vpc = object({
        id      = string
        subnets = list(string)
      })
    }))
  })

  default = {
    buildspec             = ""
    deployment_targets    = []
    environment_variables = []
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "deploy_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = {
    for i, target in var.deploy_job.deployment_targets : target.name => target
  }

  client_info = var.client_info

  job = {
    name            = "${var.client_info.project_short_name}-${var.client_info.service_name}-${each.value.name}-deploy"
    service_role    = aws_iam_role.ci_role.arn
    is_docker_build = var.ci_job.is_docker_build
    build_timeout   = var.ci_job.build_timeout
    buildspec       = var.deploy_job.buildspec

    environment_variables = concat(var.deploy_job.environment_variables, [
      { key = "ENVIRONMENT_NAME", value = each.value.name },
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = length(module.registry) <= 0 ? "" : module.registry[0].name },
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
