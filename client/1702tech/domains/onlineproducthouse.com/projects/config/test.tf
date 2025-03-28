#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "test_cloud" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/cloud/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "test_platform" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "test_api" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/apps/api/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "test_htmltopdf" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/apps/htmltopdf/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "test_batch" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/apps/batch/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "random_uuid" "test_api_key_v1" {}
resource "random_uuid" "test_htmltopdf_api_key_v1" {}

locals {
  test_env = {
    api = {
      protocol = "https"
      host     = data.terraform_remote_state.test_platform.outputs.test.ssl.api.cert_domain_name
      port     = data.terraform_remote_state.test_cloud.outputs.test.ports.api
    }

    htmltopdf = {
      protocol = "https"
      host     = data.terraform_remote_state.test_platform.outputs.test.ssl.api.cert_domain_name
      port     = data.terraform_remote_state.test_cloud.outputs.test.ports.htmltopdf
    }

    db_connection_string = join("", [
      local.test_secrets.db.protocol,
      "://",
      local.test_secrets.db.username,
      ":",
      local.test_secrets.db.password,
      "@",
      local.test_secrets.db.host,
      ":",
      local.test_secrets.db.port,
      "/",
      local.test_secrets.db.name,
    ])
  }

  test = [
    { id = "test_env_name", path = local.paths.test, key = "ENVIRONMENT_NAME", value = "test" },
    { id = "test_run_swagger", path = local.paths.test, key = "RUN_SWAGGER", value = "true" },
    { id = "test_db_connection_string", path = local.paths.test, key = "DB_CONNECTION_STRING", value = local.test_env.db_connection_string },
    { id = "test_db_protocol", path = local.paths.test, key = "DB_PROTOCOL", value = local.test_secrets.db.protocol },
    { id = "test_db_username", path = local.paths.test, key = "DB_USERNAME", value = local.test_secrets.db.username },
    { id = "test_db_password", path = local.paths.test, key = "DB_PASSWORD", value = local.test_secrets.db.password },
    { id = "test_db_host", path = local.paths.test, key = "DB_HOST", value = local.test_secrets.db.host },
    { id = "test_db_port", path = local.paths.test, key = "DB_PORT", value = local.test_secrets.db.port },
    { id = "test_db_name", path = local.paths.test, key = "DB_NAME", value = local.test_secrets.db.name },
    { id = "test_redis_connection_string", path = local.paths.test, key = "REDIS_CONNECTION_STRING", value = local.qa_env.redis_connection_string },
    { id = "test_redis_host", path = local.paths.test, key = "REDIS_HOST", value = local.qa_secrets.redis.host },
    { id = "test_redis_port", path = local.paths.test, key = "REDIS_PORT", value = local.qa_secrets.redis.port },
    { id = "test_redis_pwd", path = local.paths.test, key = "REDIS_PWD", value = local.qa_secrets.redis.pwd },
    { id = "test_sg_api_key", path = local.paths.test, key = "SG_API_KEY", value = local.qa_secrets.sg_api_key },
    { id = "test_fs_s3_bucket_name", path = local.paths.test, key = "FS_S3_BUCKET_NAME", value = data.terraform_remote_state.test_platform.outputs.test.platform.file_service.id },

    { id = "test_paystack_public_key", path = local.paths.test, key = "PAYSTACK_PUBLIC_KEY", value = local.qa_secrets.paystack.public_key },
    { id = "test_paystack_secret_key", path = local.paths.test, key = "PAYSTACK_SECRET_KEY", value = local.qa_secrets.paystack.secret_key },

    { id = "test_api_protocol", path = local.paths.test, key = "API_PROTOCOL", value = local.test_env.api.protocol },
    { id = "test_api_host", path = local.paths.test, key = "API_HOST", value = local.test_env.api.host },
    { id = "test_api_port", path = local.paths.test, key = "API_PORT", value = local.test_env.api.port },
    { id = "test_api_keys", path = local.paths.test, key = "API_KEYS", value = join(",", [
      random_uuid.test_api_key_v1.result,
    ]) },

    { id = "test_htmltopdf_protocol", path = local.paths.test, key = "HTMLTOPDF_PROTOCOL", value = local.test_env.htmltopdf.protocol },
    { id = "test_htmltopdf_host", path = local.paths.test, key = "HTMLTOPDF_HOST", value = local.test_env.htmltopdf.host },
    { id = "test_htmltopdf_port", path = local.paths.test, key = "HTMLTOPDF_PORT", value = local.test_env.htmltopdf.port },
    { id = "test_htmltopdf_keys", path = local.paths.test, key = "HTMLTOPDF_KEYS", value = join(",", [
      random_uuid.test_htmltopdf_api_key_v1.result,
    ]) },

    { id = "test_comingsoon_protocol", path = local.paths.test, key = "COMINGSOON_PROTOCOL", value = local.local_env.comingsoon.protocol },
    { id = "test_comingsoon_host", path = local.paths.test, key = "COMINGSOON_HOST", value = local.local_env.comingsoon.host },
    { id = "test_comingsoon_port", path = local.paths.test, key = "COMINGSOON_PORT", value = local.local_env.comingsoon.port },

    { id = "test_www_app_url", path = local.paths.test, key = "WWW_APP_URL", value = local.local_env.www_app_url },
    { id = "test_portal_app_url", path = local.paths.test, key = "PORTAL_APP_URL", value = local.local_env.portal_app_url },
    { id = "test_console_app_url", path = local.paths.test, key = "CONSOLE_APP_URL", value = local.local_env.console_app_url },
    { id = "test_registration_app_url", path = local.paths.test, key = "REGISTRATION_APP_URL", value = local.local_env.registration_app_url },

    { id = "test_client_api_key", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_API_KEY", value = random_uuid.test_api_key_v1.result },
    { id = "test_client_api_protocol", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_API_PROTOCOL", value = local.test_env.api.protocol },
    { id = "test_client_ws_api_protocol", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "test_client_api_host", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_API_HOST", value = local.test_env.api.host },
    { id = "test_client_api_port", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_API_PORT", value = local.test_env.api.port },
    { id = "test_client_api_base_path", path = local.paths.test, key = "VITE_APP_TEST_CLIENT_API_BASE_PATH", value = "/api/v1" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
