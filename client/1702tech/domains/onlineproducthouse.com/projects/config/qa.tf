#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "qa_cloud" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/cloud/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "qa_platform" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "qa_api" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/api/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "qa_www" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/www/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "random_uuid" "qa_api_key_v1" {}
resource "random_uuid" "qa_htmltopdf_api_key_v1" {}

locals {
  qa_env = {
    api = {
      protocol = "https"
      host     = data.terraform_remote_state.qa_api.outputs.qa.domain_name
      port     = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.port
    }

    htmltopdf = {
      protocol = "https"
      host     = data.terraform_remote_state.qa_api.outputs.qa.domain_name
      port     = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.port
    }

    www_app_url          = data.terraform_remote_state.qa_www.outputs.qa.www.www.host.id
    portal_app_url       = data.terraform_remote_state.qa_www.outputs.qa.portal.www.host.id
    console_app_url      = data.terraform_remote_state.qa_www.outputs.qa.console.www.host.id
    registration_app_url = data.terraform_remote_state.qa_www.outputs.qa.registration.www.host.id

    db_connection_string = join("", [
      local.qa_secrets.db.protocol,
      "://",
      local.qa_secrets.db.username,
      ":",
      local.qa_secrets.db.password,
      "@",
      local.qa_secrets.db.host,
      ":",
      local.qa_secrets.db.port,
      "/",
      local.qa_secrets.db.name,
    ])

    redis_connection_string = join("", [
      local.qa_secrets.redis.protocol,
      "://",
      local.qa_secrets.redis.username,
      ":",
      local.qa_secrets.redis.pwd,
      "@",
      local.qa_secrets.redis.host,
      ":",
      local.qa_secrets.redis.port,
    ])
  }

  qa = [
    { id = "qa_env_name", path = local.paths.qa, key = "ENVIRONMENT_NAME", value = "qa" },
    { id = "qa_run_swagger", path = local.paths.qa, key = "RUN_SWAGGER", value = "true" },
    { id = "qa_db_connection_string", path = local.paths.qa, key = "DB_CONNECTION_STRING", value = local.qa_env.db_connection_string },
    { id = "qa_db_protocol", path = local.paths.qa, key = "DB_PROTOCOL", value = local.qa_secrets.db.protocol },
    { id = "qa_db_username", path = local.paths.qa, key = "DB_USERNAME", value = local.qa_secrets.db.username },
    { id = "qa_db_password", path = local.paths.qa, key = "DB_PASSWORD", value = local.qa_secrets.db.password },
    { id = "qa_db_host", path = local.paths.qa, key = "DB_HOST", value = local.qa_secrets.db.host },
    { id = "qa_db_port", path = local.paths.qa, key = "DB_PORT", value = local.qa_secrets.db.port },
    { id = "qa_db_name", path = local.paths.qa, key = "DB_NAME", value = local.qa_secrets.db.name },
    { id = "qa_redis_connection_string", path = local.paths.qa, key = "REDIS_CONNECTION_STRING", value = local.qa_env.redis_connection_string },
    { id = "qa_redis_host", path = local.paths.qa, key = "REDIS_HOST", value = local.qa_secrets.redis.host },
    { id = "qa_redis_port", path = local.paths.qa, key = "REDIS_PORT", value = local.qa_secrets.redis.port },
    { id = "qa_redis_pwd", path = local.paths.qa, key = "REDIS_PWD", value = local.qa_secrets.redis.pwd },
    { id = "qa_sg_api_key", path = local.paths.qa, key = "SG_API_KEY", value = local.qa_secrets.sg_api_key },
    { id = "qa_fs_s3_bucket_name", path = local.paths.qa, key = "FS_S3_BUCKET_NAME", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.file_service.id },

    { id = "qa_paystack_public_key", path = local.paths.qa, key = "PAYSTACK_PUBLIC_KEY", value = local.qa_secrets.paystack.public_key },
    { id = "qa_paystack_secret_key", path = local.paths.qa, key = "PAYSTACK_SECRET_KEY", value = local.qa_secrets.paystack.secret_key },

    { id = "qa_api_protocol", path = local.paths.qa, key = "API_PROTOCOL", value = local.qa_env.api.protocol },
    { id = "qa_api_host", path = local.paths.qa, key = "API_HOST", value = local.qa_env.api.host },
    { id = "qa_api_port", path = local.paths.qa, key = "API_PORT", value = local.qa_env.api.port },
    { id = "qa_api_keys", path = local.paths.qa, key = "API_KEYS", value = join(",", [
      random_uuid.qa_api_key_v1.result,
    ]) },

    { id = "qa_htmltopdf_protocol", path = local.paths.qa, key = "HTMLTOPDF_PROTOCOL", value = local.qa_env.htmltopdf.protocol },
    { id = "qa_htmltopdf_host", path = local.paths.qa, key = "HTMLTOPDF_HOST", value = local.qa_env.htmltopdf.host },
    { id = "qa_htmltopdf_port", path = local.paths.qa, key = "HTMLTOPDF_PORT", value = local.qa_env.htmltopdf.port },
    { id = "qa_htmltopdf_keys", path = local.paths.qa, key = "HTMLTOPDF_KEYS", value = join(",", [
      random_uuid.qa_htmltopdf_api_key_v1.result,
    ]) },

    { id = "qa_www_app_url", path = local.paths.qa, key = "WWW_APP_URL", value = local.qa_env.www_app_url },
    { id = "qa_portal_app_url", path = local.paths.qa, key = "PORTAL_APP_URL", value = local.qa_env.portal_app_url },
    { id = "qa_console_app_url", path = local.paths.qa, key = "CONSOLE_APP_URL", value = local.qa_env.console_app_url },
    { id = "qa_registration_app_url", path = local.paths.qa, key = "REGISTRATION_APP_URL", value = local.qa_env.registration_app_url },

    { id = "qa_client_api_key", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_API_KEY", value = random_uuid.qa_api_key_v1.result },
    { id = "qa_client_api_protocol", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_API_PROTOCOL", value = local.qa_env.api.protocol },
    { id = "qa_client_ws_api_protocol", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "qa_client_api_host", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_API_HOST", value = local.qa_env.api.host },
    { id = "qa_client_api_port", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_API_PORT", value = local.qa_env.api.port },
    { id = "qa_client_api_base_path", path = local.paths.qa, key = "VITE_APP_LOCAL_CLIENT_API_BASE_PATH", value = "/api/v1" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
