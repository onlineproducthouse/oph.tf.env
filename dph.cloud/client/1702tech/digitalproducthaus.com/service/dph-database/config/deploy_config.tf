#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "deploy_env_vars" {
  source = "../../../../../../module/interface/aws/security/ssm/param_store"

  client_info = var.client_info

  parameters = [
    { path : local.paths.deploy, key : "DB_SUPER_USERNAME", value : local.secrets.test.db_username },
    { path : local.paths.deploy, key : "DB_SUPER_PASSWORD", value : local.secrets.test.db_password },
  ]
}
