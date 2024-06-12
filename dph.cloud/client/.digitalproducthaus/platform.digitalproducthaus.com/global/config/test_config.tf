#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "random_uuid" "test_api_key_v1" {}

locals {
  test = [
    { id = "test_env_name", path = local.paths.test, key = "ENVIRONMENT_NAME", value = "test" },
    { id = "test_api_host", path = local.paths.test, key = "API_HOST", value = data.terraform_remote_state.api_test_env.outputs.api.api.load_balancer.domain_name },
    { id = "test_api_port", path = local.paths.test, key = "API_PORT", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.port },
    { id = "test_www_app_url", path = local.paths.test, key = "WWW_APP_URL", value = data.terraform_remote_state.api_test_env.outputs.web.www.host.id },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

