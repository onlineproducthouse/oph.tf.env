#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-web-www/ci/terraform.tfstate"
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
      version = "4.8.0"
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

  shared_env_vars = [
    { key = "AWS_REGION", value = var.client_info.region },
    { key = "CI_FOLDER", value = "./ci" },
    { key = "PROJECT_TYPE", value = "client" },
    { key = "DEV_TOOLS_STORE_SCRIPTS", value = "s3://${data.terraform_remote_state.dph_dev_tools_store.outputs.id}" },
    { key = "LOAD_ENV_VARS_SCRIPT", value = data.terraform_remote_state.dph_ci_scripts.outputs.load_environment_variables_key },
    { key = "ENV_FILE_STORE_LOCATION", value = data.terraform_remote_state.config.outputs.test_env.content.store.id },
    { key = "ENV_FILE_NAME", value = "${var.client_info.project_short_name}-${var.client_info.service_name}.env" },
  ]

  deployment_targets = {
    test = [{
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
    registry           = false
    build_artefact     = true
    build              = true
    deployment_targets = concat(local.deployment_targets.test)
  }

  ci_job = {
    is_docker_build = false
    build_timeout   = "10"
    service_role    = ""
  }

  build_job = {
    buildspec     = "${local.dph_dev_tools_arn}${local.buildspec_key}"
    cert_store_id = data.terraform_remote_state.config.outputs.test_env.content.store.id
    cert_key      = data.terraform_remote_state.config.outputs.test_env.content.db_cert.key

    environment_variables = concat(local.shared_env_vars, [
      { key = "CI_ACTION", value = "build" },
      { key = "ENVIRONMENT_NAME", value = "ci" },
      { key = "WORKING_DIR", value = "./" },
      { key = "BUILD_ARTEFACT_PATH", value = "**" },
      { key = "AWS_SSM_PARAMETER_PATHS", value = join(";", [
        data.terraform_remote_state.config.outputs.paths.local,
        data.terraform_remote_state.config.outputs.paths.test
      ]) },
    ])
  }

  deploy_job = {
    buildspec = "${local.dph_dev_tools_arn}${local.buildspec_key}"

    environment_variables = concat(local.shared_env_vars, [
      { key = "CI_ACTION", value = "deploy" },
      { key = "AWS_SSM_PARAMETER_PATHS", value = "-1" },
      { key = "WORKING_DIR", value = "./dph.client.web/dph.client.web.www" },
      { key = "CF_INVALDIATE_SCRIPT", value = data.terraform_remote_state.dph_ci_scripts.outputs.cloudfront_invalidate_key },
      { key = "BUILD_ARTEFACT_PATH", value = "build" },
      { key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.config.outputs.test_env.web.www.host.id },
    ])
  }

  pipeline = {
    git = {
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
