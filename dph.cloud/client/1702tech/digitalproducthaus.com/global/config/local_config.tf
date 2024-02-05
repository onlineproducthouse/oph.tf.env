#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "random_uuid" "local_api_key_v1" {}
resource "random_uuid" "local_html_to_pdf_converter_api_key_v1" {}

locals {
  local_api = {
    host = "127.0.0.1"
    port = "7890"
  }
}

locals {
  local = [
    { id = "local_env_name", path = local.paths.local, key = "ENVIRONMENT_NAME", value = "local" },
    { id = "local_db_protocol", path = local.paths.local, key = "DB_PROTOCOL", value = local.secrets.local.db_protocol },
    { id = "local_db_super_username", path = local.paths.local, key = "DB_SUPER_USERNAME", value = local.secrets.local.db_super_username },
    { id = "local_db_super_pwd", path = local.paths.local, key = "DB_SUPER_PASSWORD", value = local.secrets.local.db_super_password },
    { id = "local_db_username", path = local.paths.local, key = "DB_USERNAME", value = local.secrets.local.db_username },
    { id = "local_db_pwd", path = local.paths.local, key = "DB_PASSWORD", value = local.secrets.local.db_password },
    { id = "local_db_host", path = local.paths.local, key = "DB_HOST", value = local.secrets.local.db_host },
    { id = "local_db_port", path = local.paths.local, key = "DB_PORT", value = local.secrets.local.db_port },
    { id = "local_db_name", path = local.paths.local, key = "DB_NAME", value = local.secrets.local.db_name },

    { id = "local_redis_connection_string", path = local.paths.local, key = "REDIS_CONNECTION_STRING", value = "redis://127.0.0.1:6379" },
    { id = "local_redis_host", path = local.paths.local, key = "REDIS_HOST", value = "127.0.0.1" },
    { id = "local_redis_port", path = local.paths.local, key = "REDIS_PORT", value = "6379" },

    { id = "local_api_host", path = local.paths.local, key = "API_HOST", value = local.local_api.host },
    { id = "local_api_port", path = local.paths.local, key = "API_PORT", value = local.local_api.port },
    { id = "local_api_keys", path = local.paths.local, key = "API_KEYS", value = join(",", [
      random_uuid.local_api_key_v1.result,
    ]) },

    { id = "local_sendgrid_api_key", path = local.paths.local, key = "SENDGRID_API_KEY", value = local.secrets.local.sendgrid_api_key },

    { id = "local_sms_api_sender_phone_number", path = local.paths.local, key = "SMS_API_SENDER_PHONE_NUMBER", value = local.secrets.local.sms_api_sender_phone_number },
    { id = "local_sms_api_account_sid", path = local.paths.local, key = "SMS_API_ACCOUNT_SID", value = local.secrets.local.sms_api_account_sid },
    { id = "local_sms_api_auth_token", path = local.paths.local, key = "SMS_API_AUTH_TOKEN", value = local.secrets.local.sms_api_auth_token },

    { id = "local_cloudinary_api_key", path = local.paths.local, key = "CLOUDINARY_API_KEY", value = local.secrets.local.cloudinary_api_key },
    { id = "local_cloudinary_api_secret", path = local.paths.local, key = "CLOUDINARY_API_SECRET", value = local.secrets.local.cloudinary_api_secret },
    { id = "local_cloudinary_folder", path = local.paths.local, key = "CLOUDINARY_FOLDER", value = local.secrets.local.cloudinary_folder },

    { id = "local_run_swagger", path = local.paths.local, key = "RUN_SWAGGER", value = "true" },

    { id = "local_www_app_url", path = local.paths.local, key = "WWW_APP_URL", value = "http://127.0.0.1:3000" },
    { id = "local_portal_app_url", path = local.paths.local, key = "PORTAL_APP_URL", value = "http://127.0.0.1:3001" },
    { id = "local_console_app_url", path = local.paths.local, key = "CONSOLE_APP_URL", value = "http://127.0.0.1:3002" },

    { id = "local_client_api_key", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_API_KEY", value = random_uuid.local_api_key_v1.result },
    { id = "local_client_api_protocol", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_API_PROTOCOL", value = "http" },
    { id = "local_client_ws_api_protocol", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "local_client_api_host", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_API_HOST", value = local.local_api.host },
    { id = "local_client_api_port", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_API_PORT", value = local.local_api.port },
    { id = "local_client_api_base_path", path = local.paths.local, key = "REACT_APP_LOCAL_CLIENT_API_BASE_PATH", value = "/api/v1" },

    { id = "local_file_service_storage_bucket_name", path = local.paths.local, key = "FILE_SERVICE_S3_BUCKET", value = data.terraform_remote_state.api_test_env.outputs.file_service_storage_bucket_name },

    { id = "local_html_to_pdf_converter_api_port", path = local.paths.local, key = "HTML_TO_PDF_CONVERTER_API_PORT", value = local.secrets.local.html_to_pdf_converter_api_port },
    { id = "local_html_to_pdf_converter_api_host", path = local.paths.local, key = "HTML_TO_PDF_CONVERTER_API_HOST", value = local.secrets.local.html_to_pdf_converter_api_host },
    { id = "local_html_to_pdf_converter_api_key", path = local.paths.local, key = "HTML_TO_PDF_CONVERTER_API_KEY_LIST", value = join(",", [
      random_uuid.local_html_to_pdf_converter_api_key_v1.result,
    ]) },
  ]
}
