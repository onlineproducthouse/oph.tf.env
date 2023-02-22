#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-database/ci/terraform.tfstate"
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

locals {
  dph_dev_tools_arn = data.terraform_remote_state.dph_dev_tools_store.outputs.arn
  buildspec_key     = data.terraform_remote_state.dph_ci_scripts.outputs.buildspec_key

  # aws_ssm_build_paths = [
  #   data.terraform_remote_state.ci_build_database_ssm.outputs.path,
  # ]

  # aws_ssm_deploy_paths = [
  #   data.terraform_remote_state.ci_deploy_database_ssm.outputs.path,
  #   data.terraform_remote_state.runtime_test_database_ssm.outputs.path,
  # ]
}


module "ci" {
  source = "../../../../../../module/implementation/service/ci"

  client_info = var.client_info

  config_switch = {
    build          = true
    build_artefact = true
    deploy         = false
    registry       = true
  }

  db_certs = {
    test = {
      source_path = "./content/db-cert-test.crt"
    }
  }

  build_job = {
    name            = "build-${var.client_info.project_short_name}-${var.client_info.service_name}"
    buildspec       = "${local.dph_dev_tools_arn}${local.buildspec_key}"
    is_docker_build = true

    build_timeout      = "10"
    service_role       = ""
    vpc_id             = ""
    run_in_subnet      = false
    security_group_ids = []
    subnets            = []

    environment_variables = [
      { key = "CI_ACTION", value = "build" },
      { key = "PROJECT_TYPE", value = "container" },
      { key = "ENVIRONMENT_NAME", value = "ci" },
      { key = "WORKING_DIR", value = "." },
      { key = "CI_FOLDER", value = "./ci" },
      { key = "BUILD_ARTEFACT_PATH", value = "**" },

      { key = "DEV_TOOLS_STORE_SCRIPTS", value = "s3://${data.terraform_remote_state.dph_dev_tools_store.outputs.id}" },
      { key = "LOAD_ENV_VARS_SCRIPT", value = data.terraform_remote_state.dph_ci_scripts.outputs.load_environment_variables_key },

      { key = "AWS_REGION", value = var.client_info.region },
      { key = "AWS_SSM_PARAMETER_PATHS", value = "" },
    ]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ci" {
  value = module.ci
}
