#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  deploy = [
    { id = "deploy_db_username", path = local.paths.deploy, key = "DB_SUPER_USERNAME", value = local.secrets.deploy.db_super_username },
    { id = "deploy_db_pwd", path = local.paths.deploy, key = "DB_SUPER_PASSWORD", value = local.secrets.deploy.db_super_password },
  ]
}
