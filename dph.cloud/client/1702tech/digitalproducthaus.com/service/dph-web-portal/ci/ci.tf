#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-web-portal/ci/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                      VERSIONS                     #
#                                                   #
#####################################################

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      version = "4.60.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.client_info.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "dph_dev_tools_store" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/storage/developer_tools/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "dph_ci_scripts" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "git_repo_webhook" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/developer_tools/codestar/git_repo_webhook/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "config" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/config/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  dph_dev_tools_arn = data.terraform_remote_state.dph_dev_tools_store.outputs.arn
  buildspec_key     = data.terraform_remote_state.dph_ci_scripts.outputs.buildspec_key
  buildspec         = "${local.dph_dev_tools_arn}${local.buildspec_key}"

  deployment_targets = {
    test = data.terraform_remote_state.config.outputs.platform.network.in_use != true ? [] : [{
      name = "test"
      vpc = {
        id      = ""
        subnets = []
      }
    }]
  }
}


module "ci" {
  source = "../../../../../../module/implementation/service/ci"

  client_info = var.client_info

  config_switch = {
    registry       = false
    build_artefact = true
    build          = true
  }

  ci_job = {
    is_docker_build = false
    build_timeout   = "10"
    service_role    = ""
  }

  build_job = {
    buildspec = "${local.buildspec}"

    environment_variables = concat(data.terraform_remote_state.config.outputs.ci.shared_env_vars, [
      { key = "CI_ACTION", value = "build" },
      { key = "WORKING_DIR", value = "./" },
      { key = "PROJECT_TYPE", value = "client" },
      { key = "BUILD_ARTEFACT_PATH", value = "**" },
      { key = "ENVIRONMENT_NAME", value = "ci" },
      { key = "RELEASE_ARTEFACT_PATH", value = "dph.client.web/dph.client.web.portal/build" },
      { key = "AWS_SSM_PARAMETER_PATHS", value = join(";", [
        data.terraform_remote_state.config.outputs.paths.global,
        data.terraform_remote_state.config.outputs.paths.local,
        data.terraform_remote_state.config.outputs.paths.test
      ]) },
    ])
  }

  deploy_job = {
    buildspec          = "${local.buildspec}"
    deployment_targets = concat(local.deployment_targets.test)

    environment_variables = concat(data.terraform_remote_state.config.outputs.ci.shared_env_vars, [
      { key = "CI_ACTION", value = "deploy" },
      { key = "WORKING_DIR", value = "./" },
      { key = "PROJECT_TYPE", value = "client" },
      { key = "AWS_SSM_PARAMETER_PATHS", value = join(";", [
        data.terraform_remote_state.config.outputs.paths.global,
        data.terraform_remote_state.config.outputs.paths.ci_deploy_web_portal,
      ]) },
    ])
  }

  pipeline = {
    artifacts = {
      source  = "${var.client_info.project_short_name}-${var.client_info.service_name}-source-output"
      build   = "${var.client_info.project_short_name}-${var.client_info.service_name}-build-output"
      release = "${var.client_info.project_short_name}-${var.client_info.service_name}-release-output"
    }

    git = {
      branch_names   = ["test"]
      connection_arn = data.terraform_remote_state.git_repo_webhook.outputs.arn
      repo_name      = "digitalproducttome/dph.client"
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
