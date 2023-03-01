#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  local = [
    { id = "local_env_name", path = local.paths.local, key = "ENVIRONMENT_NAME", value = "local" },
    { id = "local_db_protocol", path = local.paths.local, key = "DB_PROTOCOL", value = "postgres" },
    { id = "local_db_username", path = local.paths.local, key = "DB_USERNAME", value = "root" },
    { id = "local_db_pwd", path = local.paths.local, key = "DB_PASSWORD", value = "password" },
    { id = "local_db_host", path = local.paths.local, key = "DB_HOST", value = "127.0.0.1" },
    { id = "local_db_port", path = local.paths.local, key = "DB_PORT", value = "5432" },
    { id = "local_db_name", path = local.paths.local, key = "DB_NAME", value = "localdb" },
    { id = "local_dkr_repo", path = local.paths.local, key = "IMAGE_REGISTRY_BASE_URL", value = local.image_registry_base_url },
  ]
}
