#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/config/terraform.tfstate"
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
    service_name       = "platform"
    environment_name   = "global"
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

data "terraform_remote_state" "email" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/email/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

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

data "terraform_remote_state" "api_test_env" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-api/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  image_registry_base_url    = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com"
  test_user_email_addr_templ = "test-user@${data.terraform_remote_state.networking.outputs.dns.domain_name}"

  paths = {
    global = "/dph/config/global"
    local  = "/dph/config/local"
    test   = "/dph/config/test"

    ci_build_api      = "/dph/config/ci/build/api"
    ci_build_database = "/dph/config/ci/build/database"
    ci_build_web      = "/dph/config/ci/build/web"

    ci_deploy_api      = "/dph/config/ci/deploy/api"
    ci_deploy_database = "/dph/config/ci/deploy/database"
    ci_deploy_web      = "/dph/config/ci/deploy/web"
  }

  global = [
    { id = "global_project_name", path = local.paths.global, key = "PROJECT_NAME", value = var.client_info.project_name },
    { id = "global_do_not_reply", path = local.paths.global, key = "NO_REPLY_EMAIL_ADDRESS", value = data.terraform_remote_state.email.outputs.do_not_reply },
    { id = "global_dkr_repo", path = local.paths.global, key = "IMAGE_REGISTRY_BASE_URL", value = local.image_registry_base_url },

    { id = "global_sendgrid_sender_street", path = local.paths.global, key = "SENDGRID_SENDER_ADDRESS", value = "17 Zebra Street" },
    { id = "global_sendgrid_sender_city", path = local.paths.global, key = "SENDGRID_SENDER_CITY", value = "Bronkhorstspruit" },
    { id = "global_sendgrid_sender_state", path = local.paths.global, key = "SENDGRID_SENDER_STATE", value = "Gauteng" },
    { id = "global_sendgrid_sender_zip", path = local.paths.global, key = "SENDGRID_SENDER_ZIP", value = "1020" },

    { id = "global_sendgrid_sender_email_address", path = local.paths.global, key = "SENDGRID_SENDER_EMAIL_ADDRESS", value = data.terraform_remote_state.email.outputs.do_not_reply },
    { id = "global_sendgrid_sender_new_account_templ_id", path = local.paths.global, key = "SENDGRID_SENDER_NEW_ACCOUNT_TEMPL_ID", value = local.secrets.global.sendgrid_sender_new_account_templ_id },
    { id = "global_sendgrid_sender_recover_account_templ_id", path = local.paths.global, key = "SENDGRID_SENDER_RECOVER_ACCOUNT_TEMPL_ID", value = local.secrets.global.sendgrid_sender_recover_account_templ_id },
    { id = "global_sendgrid_sender_new_email_addr_templ_id", path = local.paths.global, key = "SENDGRID_SENDER_NEW_EMAIL_ADDR_TEMPL_ID", value = local.secrets.global.sendgrid_sender_new_email_addr_templ_id },

    { id = "global_cloudinary_cloud_name", path = local.paths.global, key = "CLOUDINARY_CLOUD_NAME", value = local.secrets.global.cloudinary_cloud_name },

    { id = "global_otp_length", path = local.paths.global, key = "OTP_LENGTH", value = "6" },
    { id = "global_otp_time_to_live_in_minutes", path = local.paths.global, key = "OTP_TIME_TO_LIVE_IN_MINUTES", value = "5" },

    { id = "global_test_user_email_addr_first", path = local.paths.global, key = "TEST_USER_EMAIL_ADDR_FIRST", value = "first.${local.test_user_email_addr_templ}" },
    { id = "global_test_user_email_addr_second", path = local.paths.global, key = "TEST_USER_EMAIL_ADDR_SECOND", value = "second.${local.test_user_email_addr_templ}" },
    { id = "global_test_user_email_addr_third", path = local.paths.global, key = "TEST_USER_EMAIL_ADDR_THIRD", value = "third.${local.test_user_email_addr_templ}" },
    { id = "global_test_user_email_addr_fourth", path = local.paths.global, key = "TEST_USER_EMAIL_ADDR_FOURTH", value = "fourth.${local.test_user_email_addr_templ}" },
    { id = "global_test_user_pwd", path = local.paths.global, key = "TEST_USER_PWD", value = local.secrets.global.test_user_password },
  ]
}

module "config" {
  source = "../../../../../module/interface/aws/security/ssm/param_store"

  client_info = var.client_info

  parameters = concat(
    local.ci_build_api,
    local.ci_build_database,
    local.ci_build_web,
    local.ci_deploy_api,
    local.ci_deploy_database,
    local.ci_deploy_web,
    local.global,
    local.local,
    local.test,
  )
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "paths" {
  value = local.paths
}

output "platform" {
  value = {
    network = data.terraform_remote_state.api_test_env.outputs.api.api.network
  }
}
