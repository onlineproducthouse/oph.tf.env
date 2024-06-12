#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "random_uuid" "local_api_key_v1" {}

locals {
  local_api = {
    host = "127.0.0.1"
    port = "7890"
  }
}

locals {
  local = [
    { id = "local_env_name", path = local.paths.local, key = "ENVIRONMENT_NAME", value = "local" },
    { id = "local_api_host", path = local.paths.local, key = "API_HOST", value = local.local_api.host },
    { id = "local_api_port", path = local.paths.local, key = "API_PORT", value = local.local_api.port },
    { id = "local_www_app_url", path = local.paths.local, key = "WWW_APP_URL", value = "http://127.0.0.1:3000" },
  ]
}
