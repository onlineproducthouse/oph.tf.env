#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "test_env" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-database/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  test = [
    { id = "test_env_name", path = local.paths.test, key = "ENVIRONMENT_NAME", value = "test" },
    { id = "test_db_protocol", path = local.paths.test, key = "DB_PROTOCOL", value = local.secrets.test.db_protocol },
    { id = "test_db_username", path = local.paths.test, key = "DB_USERNAME", value = local.secrets.test.db_username },
    { id = "test_db_pwd", path = local.paths.test, key = "DB_PASSWORD", value = local.secrets.test.db_password },
    { id = "test_db_host", path = local.paths.test, key = "DB_HOST", value = local.secrets.test.db_host },
    { id = "test_db_port", path = local.paths.test, key = "DB_PORT", value = local.secrets.test.db_port },
    { id = "test_db_name", path = local.paths.test, key = "DB_NAME", value = local.secrets.test.db_name },
    { id = "test_dkr_repo", path = local.paths.test, key = "IMAGE_REGISTRY_BASE_URL", value = local.image_registry_base_url },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "test_env" {
  value = data.terraform_remote_state.test_env.outputs
}
