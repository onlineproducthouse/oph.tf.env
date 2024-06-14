#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/ci/projects/oph_web_portal/terraform.tfstate"
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

    owner_name       = string
    owner_short_name = string

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
    key    = "client/1702tech/onlineproducthouse.com/ci/config/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  name              = "${var.client_info.owner_short_name}-${var.client_info.project_short_name}-${var.client_info.service_short_name}"
  oph_dev_tools_arn = data.terraform_remote_state.config.outputs.config.oph_dev_tools.arn
  buildspec_key     = data.terraform_remote_state.config.outputs.config.oph_ci_scripts.buildspec
  buildspec         = "${local.oph_dev_tools_arn}${local.buildspec_key}"

  deployment_targets = {
    qa = data.terraform_remote_state.config.outputs.config.qa.in_use == true ? [{
      name = "qa"

      vpc = {
        id      = ""
        subnets = []
      }
    }] : []
  }
}

module "ci" {
  source = "../../../../../../module/implementation/ci"

  ci = {
    run = data.terraform_remote_state.config.outputs.config.qa.in_use

    name            = local.name
    region          = var.client_info.region
    build_timeout   = "10"
    is_docker_build = true

    build_job = {
      buildspec = "${local.buildspec}"

      environment_variables = concat(data.terraform_remote_state.config.outputs.config.shared_ci_env_vars, [
        { key = "CI_ACTION", value = "build" },
        { key = "PROJECT_TYPE", value = "client" },
        { key = "WORKING_DIR", value = "./" },
        { key = "ENVIRONMENT_NAME", value = var.client_info.environment_short_name },
        { key = "BUILD_ARTEFACT_PATH", value = "**" },
        { key = "RELEASE_ARTEFACT_PATH", value = "oph.client.web/oph.client.web.portal/build" },
        { key = "AWS_SSM_PARAMETER_PATHS", value = join(";", [
          data.terraform_remote_state.config.outputs.paths.shared,
          data.terraform_remote_state.config.outputs.paths.local,
          data.terraform_remote_state.config.outputs.paths.qa
        ]) },
      ])
    }

    deploy_job = {
      buildspec          = "${local.buildspec}"
      deployment_targets = concat(local.deployment_targets.qa)

      environment_variables = concat(data.terraform_remote_state.config.outputs.config.shared_ci_env_vars, [
        { key = "CI_ACTION", value = "deploy" },
        { key = "PROJECT_TYPE", value = "container" },
        { key = "WORKING_DIR", value = "./" },
        { key = "AWS_SSM_PARAMETER_PATHS", value = join(";", [
          data.terraform_remote_state.config.outputs.config.paths.shared,
          data.terraform_remote_state.config.outputs.config.paths.ci.deploy.website.portal.qa,
          data.terraform_remote_state.config.outputs.config.paths.qa,
        ]) },
      ])
    }

    pipeline = {
      artifacts = {
        source  = "${local.name}-source-output"
        build   = "${local.name}-build-output"
        release = "${local.name}-release-output"
      }

      git = {
        branch_names   = ["qa"]
        connection_arn = data.terraform_remote_state.config.outputs.config.git_repo_webhook.arn
        repo_name      = "${data.terraform_remote_state.config.outputs.config.git_repo_webhook.bitbucket_account_name}/oph.client"
      }
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
