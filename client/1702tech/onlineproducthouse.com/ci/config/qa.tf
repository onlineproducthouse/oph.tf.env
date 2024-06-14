#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "qa" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/environments/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

resource "random_uuid" "qa_api_key_v1" {}
resource "random_uuid" "qa_htmltopdf_api_key_v1" {}

locals {
  qa = {
    api = {
      protocol = "https"
      host     = data.terraform_remote_state.qa.outputs.qa.api.api.load_balancer.domain_name
      port     = "${data.terraform_remote_state.qa.outputs.qa.api.api.container.port}"
    }

    htmltopdf = {
      protocol = "https"
      host     = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.load_balancer.domain_name
      port     = "${data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.port}"
    }

    www_app_url     = data.terraform_remote_state.qa.outputs.qa.web.www.host.id
    portal_app_url  = data.terraform_remote_state.qa.outputs.qa.web.portal.host.id
    console_app_url = data.terraform_remote_state.qa.outputs.qa.web.console.host.id

    db_connection_string = join("", [
      local.secrets.qa.db.protocol,
      "://",
      local.secrets.qa.db.username,
      ":",
      local.secrets.qa.db.password,
      "@",
      local.secrets.qa.db.host,
      ":",
      local.secrets.qa.db.port,
      "/",
      local.secrets.qa.db.name,
    ])

    redis_connection_string = join("", [
      local.secrets.qa.redis.protocol,
      "://",
      local.secrets.qa.redis.username,
      ":",
      local.secrets.qa.redis.pwd,
      "@",
      local.secrets.qa.redis.host,
      ":",
      local.secrets.qa.redis.port,
    ])
  }
}

locals {
  qa = [
    { id = "qa_env_name", path = local.paths.qa, key = "ENVIRONMENT_NAME", value = "qa" },
    { id = "qa_run_swagger", path = local.paths.qa, key = "RUN_SWAGGER", value = "true" },
    { id = "qa_db_connection_string", path = local.paths.qa, key = "DB_CONNECTION_STRING", value = local.qa.db_connection_string },
    { id = "qa_redis_connection_string", path = local.paths.qa, key = "REDIS_CONNECTION_STRING", value = local.qa.redis_connection_string },
    { id = "qa_sg_api_key", path = local.paths.qa, key = "SG_API_KEY", value = local.secrets.qa.sg_api_key },
    { id = "qa_fs_s3_bucket_name", path = local.paths.qa, key = "FS_S3_BUCKET_NAME", value = data.terraform_remote_state.qa.outputs.qa.environment.file_service.bucket_name },

    { id = "qa_paystack_public_key", path = local.paths.qa, key = "PAYSTACK_PUBLIC_KEY", value = local.secrets.qa.paystack.public_key },
    { id = "qa_paystack_secret_key", path = local.paths.qa, key = "PAYSTACK_SECRET_KEY", value = local.secrets.qa.paystack.secret_key },

    { id = "qa_api_protocol", path = local.paths.qa, key = "API_PROTOCOL", value = local.qa.api.protocol },
    { id = "qa_api_host", path = local.paths.qa, key = "API_HOST", value = local.qa.api.host },
    { id = "qa_api_port", path = local.paths.qa, key = "API_PORT", value = local.qa.api.port },
    { id = "qa_api_keys", path = local.paths.qa, key = "API_KEYS", value = join(",", [
      random_uuid.qa_api_key_v1.result,
    ]) },

    { id = "qa_htmltopdf_protocol", path = local.paths.qa, key = "HTMLTOPDF_PROTOCOL", value = local.qa.htmltopdf.protocol },
    { id = "qa_htmltopdf_host", path = local.paths.qa, key = "HTMLTOPDF_HOST", value = local.qa.htmltopdf.host },
    { id = "qa_htmltopdf_port", path = local.paths.qa, key = "HTMLTOPDF_PORT", value = local.qa.htmltopdf.port },
    { id = "qa_htmltopdf_keys", path = local.paths.qa, key = "HTMLTOPDF_KEYS", value = join(",", [
      random_uuid.qa_htmltopdf_api_key_v1.result,
    ]) },

    { id = "qa_www_app_url", path = local.paths.qa, key = "WWW_APP_URL", value = local.qa.www_app_url },
    { id = "qa_portal_app_url", path = local.paths.qa, key = "PORTAL_APP_URL", value = local.qa.portal_app_url },
    { id = "qa_console_app_url", path = local.paths.qa, key = "CONSOLE_APP_URL", value = local.qa.console_app_url },

    { id = "qa_client_api_key", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_API_KEY", value = random_uuid.qa_api_key_v1.result },
    { id = "qa_client_api_protocol", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_API_PROTOCOL", value = local.qa.api.protocol },
    { id = "qa_client_ws_api_protocol", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_WS_API_PROTOCOL", value = "ws" },
    { id = "qa_client_api_host", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_API_HOST", value = local.qa.api.host },
    { id = "qa_client_api_port", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_API_PORT", value = local.qa.api.port },
    { id = "qa_client_api_base_path", path = local.paths.qa, key = "VUE_APP_LOCAL_CLIENT_API_BASE_PATH", value = "/api/v1" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
