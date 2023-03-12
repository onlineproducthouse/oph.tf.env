#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "api_test_env" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-api/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "random_uuid" "test_api_key_v1" {}

locals {
  test = [
    { id = "test_env_name", path = local.paths.test, key = "ENVIRONMENT_NAME", value = "test" },
    { id = "test_db_protocol", path = local.paths.test, key = "DB_PROTOCOL", value = local.secrets.test.db_protocol },
    { id = "test_db_username", path = local.paths.test, key = "DB_USERNAME", value = local.secrets.test.db_username },
    { id = "test_db_pwd", path = local.paths.test, key = "DB_PASSWORD", value = local.secrets.test.db_password },
    { id = "test_db_host", path = local.paths.test, key = "DB_HOST", value = local.secrets.test.db_host },
    { id = "test_db_port", path = local.paths.test, key = "DB_PORT", value = local.secrets.test.db_port },
    { id = "test_db_name", path = local.paths.test, key = "DB_NAME", value = local.secrets.test.db_name },

    { id = "test_redis_connection_string", path = local.paths.test, key = "REDIS_CONNECTION_STRING", value = local.secrets.test.redis_connection_string },
    { id = "test_redis_host", path = local.paths.test, key = "REDIS_HOST", value = local.secrets.test.redis_host },
    { id = "test_redis_port", path = local.paths.test, key = "REDIS_PORT", value = local.secrets.test.redis_port },

    { id = "test_api_host", path = local.paths.test, key = "API_HOST", value = data.terraform_remote_state.api_test_env.outputs.api.load_balancer.domain_name },
    { id = "test_api_port", path = local.paths.test, key = "API_PORT", value = data.terraform_remote_state.api_test_env.outputs.api.port },
    { id = "test_api_keys", path = local.paths.test, key = "API_KEYS", value = join(",", [
      random_uuid.test_api_key_v1.result,
    ]) },

    { id = "test_sendgrid_api_key", path = local.paths.test, key = "SENDGRID_API_KEY", value = local.secrets.test.sendgrid_api_key },

    { id = "test_sms_api_sender_phone_number", path = local.paths.test, key = "SMS_API_SENDER_PHONE_NUMBER", value = local.secrets.test.sms_api_sender_phone_number },
    { id = "test_sms_api_account_sid", path = local.paths.test, key = "SMS_API_ACCOUNT_SID", value = local.secrets.test.sms_api_account_sid },
    { id = "test_sms_api_auth_token", path = local.paths.test, key = "SMS_API_AUTH_TOKEN", value = local.secrets.test.sms_api_auth_token },

    { id = "test_cloudinary_api_key", path = local.paths.test, key = "CLOUDINARY_API_KEY", value = local.secrets.test.cloudinary_api_key },
    { id = "test_cloudinary_api_secret", path = local.paths.test, key = "CLOUDINARY_API_SECRET", value = local.secrets.test.cloudinary_api_secret },
    { id = "test_cloudinary_folder", path = local.paths.test, key = "CLOUDINARY_FOLDER", value = local.secrets.test.cloudinary_folder },

    { id = "test_run_swagger", path = local.paths.test, key = "RUN_SWAGGER", value = "true" },

    { id = "test_www_app_url", path = local.paths.test, key = "WWW_APP_URL", value = data.terraform_remote_state.api_test_env.outputs.web.www.host.id },
    { id = "test_portal_app_url", path = local.paths.test, key = "PORTAL_APP_URL", value = data.terraform_remote_state.api_test_env.outputs.web.portal.host.id },
    { id = "test_console_app_url", path = local.paths.test, key = "CONSOLE_APP_URL", value = data.terraform_remote_state.api_test_env.outputs.web.console.host.id },

    { id = "test_client_api_key", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_API_KEY", value = random_uuid.test_api_key_v1.result },
    { id = "test_client_api_protocol", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_API_PROTOCOL", value = "https" },
    { id = "test_client_ws_api_protocol", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "test_client_api_host", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_API_HOST", value = data.terraform_remote_state.api_test_env.outputs.api.load_balancer.domain_name },
    { id = "test_client_api_port", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_API_PORT", value = data.terraform_remote_state.api_test_env.outputs.api.port },
    { id = "test_client_api_base_path", path = local.paths.test, key = "REACT_APP_TEST_CLIENT_API_BASE_PATH", value = "/api/v1" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "test_env" {
  value = data.terraform_remote_state.api_test_env.outputs
}
