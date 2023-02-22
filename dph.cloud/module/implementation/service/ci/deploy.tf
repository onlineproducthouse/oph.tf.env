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

module "deploy_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  for_each = {
    for i, target in var.config_switch.deployment_targets : target => target
  }

  client_info = var.client_info
  job = {
    name            = "deploy-${var.client_info.project_short_name}-${var.client_info.service_name}"
    service_role    = aws_iam_role.ci_role.arn
    is_docker_build = var.ci_job.is_docker_build
    build_timeout   = var.ci_job.build_timeout
    buildspec       = var.deploy_job.buildspec

    environment_variables = concat(var.deploy_job.environment_variables, [
      { key = "ENVIRONMENT_NAME", value = each.value },
    ])
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
