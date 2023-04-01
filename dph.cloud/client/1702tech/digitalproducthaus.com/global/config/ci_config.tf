#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  ci_build_api = []

  ci_build_database = []

  ci_build_web = []

  ci_deploy_api = [
    { id = "ci_deploy_api_task_fam", path = local.paths.ci_deploy_api, key = "TASK_FAMILY", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.task_definition_family },
    { id = "ci_deploy_api_task_role_arn", path = local.paths.ci_deploy_api, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.task_role_arn },
    { id = "ci_deploy_api_container_name", path = local.paths.ci_deploy_api, key = "CONTAINER_NAME", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.container_name },
    { id = "ci_deploy_api_container_cpu", path = local.paths.ci_deploy_api, key = "CONTAINER_CPU", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.cpu },
    { id = "ci_deploy_api_container_mem_res", path = local.paths.ci_deploy_api, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.memory },
    { id = "ci_deploy_api_container_port", path = local.paths.ci_deploy_api, key = "CONTAINER_PORT", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.port },
    { id = "ci_deploy_api_cluster_name", path = local.paths.ci_deploy_api, key = "CLUSTER_NAME", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.cluster_name },
    { id = "ci_deploy_api_svc_name", path = local.paths.ci_deploy_api, key = "SERVICE_NAME", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.service_name },

    { id = "ci_deploy_api_log_driver", path = local.paths.ci_deploy_api, key = "LOG_DRIVER", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.logging.driver },
    { id = "ci_deploy_api_log_group", path = local.paths.ci_deploy_api, key = "LOG_GROUP", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.logging.group },
    { id = "ci_deploy_api_log_prefix", path = local.paths.ci_deploy_api, key = "LOG_PREFIX", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.logging.prefix },

    { id = "ci_deploy_api_port_mapping_name", path = local.paths.ci_deploy_api, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.port_mapping_name },
    { id = "ci_deploy_api_network_mode", path = local.paths.ci_deploy_api, key = "NETWORK_MODE", value = data.terraform_remote_state.api_test_env.outputs.api.api.container.network_mode },
  ]

  ci_deploy_database = [
    { id = "ci_deploy_database_db_username", path = local.paths.ci_deploy_database, key = "DB_SUPER_USERNAME", value = local.secrets.ci_deploy_database.db_super_username },
    { id = "ci_deploy_database_db_pwd", path = local.paths.ci_deploy_database, key = "DB_SUPER_PASSWORD", value = local.secrets.ci_deploy_database.db_super_password },
  ]

  ci_deploy_web = {
    storybook = [
      { id = "ci_deploy_web_storybook_s3_host_bucket_url", path = local.paths.ci_deploy_web_storybook, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.api_test_env.outputs.web.storybook.host.id },
      { id = "ci_deploy_web_storybook_cdn_id", path = local.paths.ci_deploy_web_storybook, key = "CDN_ID", value = data.terraform_remote_state.api_test_env.outputs.web.storybook.cdn.id },
    ]
    www = [
      { id = "ci_deploy_web_www_s3_host_bucket_url", path = local.paths.ci_deploy_web_www, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.api_test_env.outputs.web.www.host.id },
      { id = "ci_deploy_web_www_cdn_id", path = local.paths.ci_deploy_web_www, key = "CDN_ID", value = data.terraform_remote_state.api_test_env.outputs.web.www.cdn.id },
    ]
    portal = [
      { id = "ci_deploy_web_portal_s3_host_bucket_url", path = local.paths.ci_deploy_web_portal, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.api_test_env.outputs.web.portal.host.id },
      { id = "ci_deploy_web_portal_cdn_id", path = local.paths.ci_deploy_web_portal, key = "CDN_ID", value = data.terraform_remote_state.api_test_env.outputs.web.portal.cdn.id },
    ]
    console = [
      { id = "ci_deploy_web_console_s3_host_bucket_url", path = local.paths.ci_deploy_web_console, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.api_test_env.outputs.web.console.host.id },
      { id = "ci_deploy_web_console_cdn_id", path = local.paths.ci_deploy_web_console, key = "CDN_ID", value = data.terraform_remote_state.api_test_env.outputs.web.console.cdn.id },
    ]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ci" {
  value = {
    shared_env_vars = [
      { key = "AWS_REGION", value = var.client_info.region },
      { key = "CI_FOLDER", value = "./ci" },
      { key = "DEV_TOOLS_STORE_SCRIPTS", value = "s3://${data.terraform_remote_state.dph_dev_tools_store.outputs.id}" },
      { key = "LOAD_ENV_VARS_SCRIPT", value = data.terraform_remote_state.dph_ci_scripts.outputs.load_environment_variables_key },
      { key = "ENV_FILE_STORE_LOCATION", value = data.terraform_remote_state.api_test_env.outputs.content.store.id },
      { key = "ENV_FILE_NAME", value = "${var.client_info.project_short_name}-${var.client_info.service_name}.env" },
      { key = "CERT_STORE", value = "s3://${data.terraform_remote_state.api_test_env.outputs.content.store.id}" },
      { key = "CERT_NAME", value = data.terraform_remote_state.api_test_env.outputs.content.db_cert.key },
      { key = "POST_BUILD_SCRIPT_KEY", value = data.terraform_remote_state.dph_ci_scripts.outputs.post_build_script_key },
    ]
  }
}
