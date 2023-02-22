#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "build_job" {
  type = object({
    name            = string
    service_role    = string
    build_timeout   = string
    buildspec       = string
    is_docker_build = bool
    environment_variables = list(object({
      key   = string
      value = string
    }))
    run_in_subnet      = bool
    vpc_id             = string
    subnets            = list(string)
    security_group_ids = list(string)
  })

  default = {
    build_timeout         = "10"
    buildspec             = ""
    environment_variables = []
    is_docker_build       = false
    name                  = "UnknownCodeBuild"
    run_in_subnet         = false
    security_group_ids    = []
    service_role          = ""
    subnets               = []
    vpc_id                = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "build_job" {
  source      = "../../../interface/aws/developer_tools/codebuild/projects"
  client_info = var.client_info
  build_job = {
    name            = var.build_job.name
    buildspec       = var.build_job.buildspec
    is_docker_build = var.build_job.is_docker_build
    service_role    = aws_iam_role.ci_role.arn

    build_timeout      = "10"
    run_in_subnet      = false
    security_group_ids = []
    subnets            = []
    vpc_id             = ""

    environment_variables = concat(var.build_job.environment_variables, [
      { key = "CERT_STORE", value = "s3://${module.store.id}" },
      { key = "CERT_NAME", value = module.db_cert_test[0].key },
    ])
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
