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

resource "random_uuid" "test_www_api_key_v1" {}
resource "random_uuid" "test_portal_api_key_v1" {}
resource "random_uuid" "test_console_api_key_v1" {}

locals {
  test = [
    { id = "test_env_name", path = local.paths.test, key = "ENVIRONMENT_NAME", value = "local" },
    { id = "test_db_protocol", path = local.paths.test, key = "DB_PROTOCOL", value = local.secrets.test.db_protocol },
    { id = "test_db_username", path = local.paths.test, key = "DB_USERNAME", value = local.secrets.test.db_username },
    { id = "test_db_pwd", path = local.paths.test, key = "DB_PASSWORD", value = local.secrets.test.db_password },
    { id = "test_db_host", path = local.paths.test, key = "DB_HOST", value = local.secrets.test.db_host },
    { id = "test_db_port", path = local.paths.test, key = "DB_PORT", value = local.secrets.test.db_port },
    { id = "test_db_name", path = local.paths.test, key = "DB_NAME", value = local.secrets.test.db_name },

    { id = "test_redis_connection_string", path = local.paths.test, key = "REDIS_CONNECTION_STRING", value = "redis://127.0.0.1:6379" },
    { id = "test_redis_host", path = local.paths.test, key = "REDIS_HOST", value = "127.0.0.1" },
    { id = "test_redis_port", path = local.paths.test, key = "REDIS_PORT", value = "6379" },

    { id = "test_api_host", path = local.paths.test, key = "API_HOST", value = "127.0.0.1" },
    { id = "test_api_keys", path = local.paths.test, key = "API_KEYS", value = join(",", [
      random_uuid.test_www_api_key_v1.result,
      random_uuid.test_portal_api_key_v1.result,
      random_uuid.test_console_api_key_v1.result,
    ]) },

    { id = "test_sendgrid_api_key", path = local.paths.test, key = "SENDGRID_API_KEY", value = local.secrets.test.sendgrid_api_key },

    { id = "test_sms_api_sender_phone_number", path = local.paths.test, key = "SMS_API_SENDER_PHONE_NUMBER", value = local.secrets.test.sms_api_sender_phone_number },
    { id = "test_sms_api_account_sid", path = local.paths.test, key = "SMS_API_ACCOUNT_SID", value = local.secrets.test.sms_api_account_sid },
    { id = "test_sms_api_auth_token", path = local.paths.test, key = "SMS_API_AUTH_TOKEN", value = local.secrets.test.sms_api_auth_token },

    { id = "test_cloudinary_api_key", path = local.paths.test, key = "CLOUDINARY_API_KEY", value = local.secrets.test.cloudinary_api_key },
    { id = "test_cloudinary_api_secret", path = local.paths.test, key = "CLOUDINARY_API_SECRET", value = local.secrets.test.cloudinary_api_secret },
    { id = "test_cloudinary_folder", path = local.paths.test, key = "CLOUDINARY_FOLDER", value = local.secrets.test.cloudinary_folder },

    { id = "test_run_swagger", path = local.paths.test, key = "RUN_SWAGGER", value = "true" },

    { id = "test_www_app_url", path = local.paths.test, key = "WWW_APP_URL", value = "http://127.0.0.1:3000" },
    { id = "test_portal_app_url", path = local.paths.test, key = "PORTAL_APP_URL", value = "http://127.0.0.1:3001" },
    { id = "test_console_app_url", path = local.paths.test, key = "CONSOLE_APP_URL", value = "http://127.0.0.1:3002" },
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
