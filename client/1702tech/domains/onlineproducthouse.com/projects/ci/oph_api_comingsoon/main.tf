#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/ci/oph_api_comingsoon/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "config" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/config/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "random_uuid" "artifact_source_output" {}

locals {
  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}"

  oph_dev_tools_arn = data.terraform_remote_state.config.outputs.config.oph_dev_tools.arn
  buildspec_key     = data.terraform_remote_state.config.outputs.config.oph_ci_scripts.buildspec

  buildspec = "${local.oph_dev_tools_arn}${local.buildspec_key}"

  artifacts = {
    source = random_uuid.artifact_source_output.result
  }

  git = {
    connection_arn = data.terraform_remote_state.config.outputs.config.git_repo_webhook.arn
    repo_name      = "${data.terraform_remote_state.config.outputs.config.git_repo_webhook.bitbucket_account_name}/oph.api.comingsoon"
  }

  jobs = {
    build = [
      {
        buildspec   = local.buildspec
        timeout     = "5"
        branch_name = "main"

        environment_variables = concat(data.terraform_remote_state.config.outputs.config.shared_ci_env_vars, [
          { key = "CI_ACTION", value = "build" },
          { key = "PROJECT_TYPE", value = "container" },
          { key = "WORKING_DIR", value = "./" },
          { key = "ENVIRONMENT_NAME", value = var.client_info.environment_short_name },
          { key = "BUILD_ARTEFACT_PATH", value = "**/**/*" },
          { key = "RELEASE_ARTEFACT_PATH", value = "./" },
          { key = "AWS_SSM_PARAMETER_PATHS", value = data.terraform_remote_state.config.outputs.config.paths.shared },
        ])
      },
    ]

    release = []
  }
}

module "ci" {
  source = "../../../../../../../module/implementation/projects/ci"

  ci = {
    name         = local.name
    region       = var.client_info.region
    is_container = true
    jobs         = local.jobs
  }
}

module "notifications" {
  source = "../../../../../../../module/implementation/projects/ci/notifications"

  for_each = { for v in aws_codepipeline.pipelines : v.name => v }

  notifications = {
    name                = each.value.name
    pipeline_arn        = each.value.arn
    alert_email_address = data.terraform_remote_state.config.outputs.config.email.ci_alerts
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
