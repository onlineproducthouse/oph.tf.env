#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "test_env_vars" {
  source = "../../../../../../module/interface/aws/security/ssm/param_store"

  client_info = var.client_info

  parameters = [
    { path : local.paths.test, key : "ENVIRONMENT_NAME", value : "test" },
    { path : local.paths.test, key : "DB_PROTOCOL", value : local.secrets.test.db_protocol },
    { path : local.paths.test, key : "DB_USERNAME", value : local.secrets.test.db_username },
    { path : local.paths.test, key : "DB_PASSWORD", value : local.secrets.test.db_password },
    { path : local.paths.test, key : "DB_HOST", value : local.secrets.test.db_host },
    { path : local.paths.test, key : "DB_PORT", value : local.secrets.test.db_port },
    { path : local.paths.test, key : "DB_NAME", value : local.secrets.test.db_name },
    { path : local.paths.test, key : "IMAGE_REGISTRY_BASE_URL", value : local.image_registry_base_url },
  ]
}
