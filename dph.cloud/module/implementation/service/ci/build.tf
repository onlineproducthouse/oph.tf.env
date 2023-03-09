#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "build_job" {
  type = object({
    buildspec     = string
    cert_store_id = string
    cert_key      = string
    environment_variables = list(object({
      key   = string
      value = string
    }))
  })

  default = {
    buildspec             = ""
    cert_store_id         = ""
    cert_key              = ""
    environment_variables = []
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "build_job" {
  source = "../../../interface/aws/developer_tools/codebuild/projects"

  count = var.config_switch.build == true ? 1 : 0

  client_info = var.client_info
  job = {
    name            = "build-${var.client_info.project_short_name}-${var.client_info.service_name}"
    service_role    = aws_iam_role.ci_role.arn
    is_docker_build = var.ci_job.is_docker_build
    build_timeout   = var.ci_job.build_timeout
    buildspec       = var.build_job.buildspec

    environment_variables = concat(var.build_job.environment_variables, [
      { key = "CERT_STORE", value = "s3://${var.build_job.cert_store_id}" },
      { key = "CERT_NAME", value = var.build_job.cert_key },
      { key = "IMAGE_REGISTRY_BASE_URL", value = local.registry.base_url },
      { key = "IMAGE_REPOSITORY_NAME", value = length(module.registry) <= 0 ? "" : module.registry[0].name },
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
