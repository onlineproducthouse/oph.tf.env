#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "random_uuid" "local_api_key_v1" {}
resource "random_uuid" "local_htmltopdf_api_key_v1" {}

locals {
  local = {
    api = {
      protocol = "http"
      host     = "127.0.0.1"
      port     = "7890"
    }

    htmltopdf = {
      protocol = "http"
      host     = "127.0.0.1"
      port     = "7891"
    }

    www_app_url     = "http://127.0.0.1:3000"
    portal_app_url  = "http://127.0.0.1:3001"
    console_app_url = "http://127.0.0.1:3002"
  }
}

locals {
  local = [
    { id = "local_env_name", path = local.paths.local, key = "ENVIRONMENT_NAME", value = "local" },
    { id = "local_run_swagger", path = local.paths.local, key = "RUN_SWAGGER", value = "true" },
    { id = "local_db_connection_string", path = local.paths.local, key = "DB_CONNECTION_STRING", value = "postgres://root:password@127.0.0.1:5432/localdb" },
    { id = "local_redis_connection_string", path = local.paths.local, key = "REDIS_CONNECTION_STRING", value = "redis://127.0.0.1:6379" },
    { id = "local_sg_api_key", path = local.paths.local, key = "SG_API_KEY", value = local.secrets.qa.sg_api_key },
    { id = "local_fs_s3_bucket_name", path = local.paths.local, key = "FS_S3_BUCKET_NAME", value = data.terraform_remote_state.qa.outputs.qa.environment.file_service.bucket_name },

    { id = "local_paystack_public_key", path = local.paths.local, key = "PAYSTACK_PUBLIC_KEY", value = local.secrets.qa.paystack.public_key },
    { id = "local_paystack_secret_key", path = local.paths.local, key = "PAYSTACK_SECRET_KEY", value = local.secrets.qa.paystack.secret_key },

    { id = "local_api_protocol", path = local.paths.local, key = "API_PROTOCOL", value = local.local.api.protocol },
    { id = "local_api_host", path = local.paths.local, key = "API_HOST", value = local.local.api.host },
    { id = "local_api_port", path = local.paths.local, key = "API_PORT", value = local.local.api.port },
    { id = "local_api_keys", path = local.paths.local, key = "API_KEYS", value = join(",", [
      random_uuid.local_api_key_v1.result,
    ]) },

    { id = "local_htmltopdf_protocol", path = local.paths.local, key = "HTMLTOPDF_PROTOCOL", value = local.local.htmltopdf.protocol },
    { id = "local_htmltopdf_host", path = local.paths.local, key = "HTMLTOPDF_HOST", value = local.local.htmltopdf.host },
    { id = "local_htmltopdf_port", path = local.paths.local, key = "HTMLTOPDF_PORT", value = local.local.htmltopdf.port },
    { id = "local_htmltopdf_keys", path = local.paths.local, key = "HTMLTOPDF_KEYS", value = join(",", [
      random_uuid.local_htmltopdf_api_key_v1.result,
    ]) },

    { id = "local_www_app_url", path = local.paths.local, key = "WWW_APP_URL", value = local.local.www_app_url },
    { id = "local_portal_app_url", path = local.paths.local, key = "PORTAL_APP_URL", value = local.local.portal_app_url },
    { id = "local_console_app_url", path = local.paths.local, key = "CONSOLE_APP_URL", value = local.local.console_app_url },

    { id = "local_client_api_key", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_API_KEY", value = random_uuid.local_api_key_v1.result },
    { id = "local_client_api_protocol", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_API_PROTOCOL", value = local.local.api.protocol },
    { id = "local_client_ws_api_protocol", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "local_client_api_host", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_API_HOST", value = local.local.api.host },
    { id = "local_client_api_port", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_API_PORT", value = local.local.api.port },
    { id = "local_client_api_base_path", path = local.paths.local, key = "VUE_APP_LOCAL_CLIENT_API_BASE_PATH", value = "/api/v1" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
