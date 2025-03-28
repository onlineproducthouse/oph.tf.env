#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "dev_tools_store" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/storage/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "ci_scripts" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  cdn = {
    storybook    = data.terraform_remote_state.qa_www.outputs.qa.storybook.www.cdn.id == "" ? "_" : data.terraform_remote_state.qa_www.outputs.qa.storybook.www.cdn.id
    www          = data.terraform_remote_state.qa_www.outputs.qa.www.www.cdn.id == "" ? "_" : data.terraform_remote_state.qa_www.outputs.qa.www.www.cdn.id
    portal       = data.terraform_remote_state.qa_www.outputs.qa.portal.www.cdn.id == "" ? "_" : data.terraform_remote_state.qa_www.outputs.qa.portal.www.cdn.id
    console      = data.terraform_remote_state.qa_www.outputs.qa.console.www.cdn.id == "" ? "_" : data.terraform_remote_state.qa_www.outputs.qa.console.www.cdn.id
    registration = data.terraform_remote_state.qa_www.outputs.qa.registration.www.cdn.id == "" ? "_" : data.terraform_remote_state.qa_www.outputs.qa.registration.www.cdn.id
  }

  ci = {
    build = {
      container = {
        api       = []
        htmltopdf = []
      }

      db = {
        api = []
      }

      website = {
        storybook    = []
        www          = []
        portal       = []
        console      = []
        registration = []
      }
    }

    deploy = {
      container = {
        api = {
          qa = [
            { id = "ci_deploy_cntnr_api_qa_task_fam", path = local.paths.ci.deploy.container.api.qa, key = "TASK_FAMILY", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.task_definition_family },
            { id = "ci_deploy_cntnr_api_qa_task_role_arn", path = local.paths.ci.deploy.container.api.qa, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.task_role_arn },
            { id = "ci_deploy_cntnr_api_qa_cntnr_name", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.container_name },
            { id = "ci_deploy_cntnr_api_qa_cntnr_cpu", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_CPU", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.cpu },
            { id = "ci_deploy_cntnr_api_qa_cntnr_mem_res", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.memory },
            { id = "ci_deploy_cntnr_api_qa_cntnr_port", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_PORT", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.port },
            { id = "ci_deploy_cntnr_api_qa_cluster_name", path = local.paths.ci.deploy.container.api.qa, key = "CLUSTER_NAME", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.compute.cluster_name },
            { id = "ci_deploy_cntnr_api_qa_svc_name", path = local.paths.ci.deploy.container.api.qa, key = "SERVICE_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.service_name },

            { id = "ci_deploy_cntnr_api_qa_log_driver", path = local.paths.ci.deploy.container.api.qa, key = "LOG_DRIVER", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.driver },
            { id = "ci_deploy_cntnr_api_qa_log_group", path = local.paths.ci.deploy.container.api.qa, key = "LOG_GROUP", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.group },
            { id = "ci_deploy_cntnr_api_qa_log_prefix", path = local.paths.ci.deploy.container.api.qa, key = "LOG_PREFIX", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.prefix },

            { id = "ci_deploy_cntnr_api_qa_port_mapping_name", path = local.paths.ci.deploy.container.api.qa, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.port_mapping_name },
            { id = "ci_deploy_cntnr_api_qa_network_mode", path = local.paths.ci.deploy.container.api.qa, key = "NETWORK_MODE", value = data.terraform_remote_state.qa_api.outputs.qa.api.api.container.network_mode },
          ]

          test = [
            { id = "ci_deploy_cntnr_api_test_task_fam", path = local.paths.ci.deploy.container.api.test, key = "TASK_FAMILY", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.task_definition_family },
            { id = "ci_deploy_cntnr_api_test_task_role_arn", path = local.paths.ci.deploy.container.api.test, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.task_role_arn },
            { id = "ci_deploy_cntnr_api_test_cntnr_name", path = local.paths.ci.deploy.container.api.test, key = "CONTAINER_NAME", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.container_name },
            { id = "ci_deploy_cntnr_api_test_cntnr_cpu", path = local.paths.ci.deploy.container.api.test, key = "CONTAINER_CPU", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.cpu },
            { id = "ci_deploy_cntnr_api_test_cntnr_mem_res", path = local.paths.ci.deploy.container.api.test, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.memory },
            { id = "ci_deploy_cntnr_api_test_cntnr_port", path = local.paths.ci.deploy.container.api.test, key = "CONTAINER_PORT", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.port },
            { id = "ci_deploy_cntnr_api_test_cluster_name", path = local.paths.ci.deploy.container.api.test, key = "CLUSTER_NAME", value = data.terraform_remote_state.test_platform.outputs.test.platform.compute.htmltopdf.cluster_name },
            { id = "ci_deploy_cntnr_api_test_svc_name", path = local.paths.ci.deploy.container.api.test, key = "SERVICE_NAME", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.service_name },

            { id = "ci_deploy_cntnr_api_test_log_driver", path = local.paths.ci.deploy.container.api.test, key = "LOG_DRIVER", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.driver },
            { id = "ci_deploy_cntnr_api_test_log_group", path = local.paths.ci.deploy.container.api.test, key = "LOG_GROUP", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.group },
            { id = "ci_deploy_cntnr_api_test_log_prefix", path = local.paths.ci.deploy.container.api.test, key = "LOG_PREFIX", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.prefix },

            { id = "ci_deploy_cntnr_api_test_port_mapping_name", path = local.paths.ci.deploy.container.api.test, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.port_mapping_name },
            { id = "ci_deploy_cntnr_api_test_network_mode", path = local.paths.ci.deploy.container.api.test, key = "NETWORK_MODE", value = data.terraform_remote_state.test_api.outputs.test.api.api.container.network_mode },
          ]
        }

        htmltopdf = {
          qa = [
            { id = "ci_deploy_cntnr_htmltopdf_qa_task_fam", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "TASK_FAMILY", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.task_definition_family },
            { id = "ci_deploy_cntnr_htmltopdf_qa_task_role_arn", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.task_role_arn },
            { id = "ci_deploy_cntnr_htmltopdf_qa_cntnr_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.container_name },
            { id = "ci_deploy_cntnr_htmltopdf_qa_cntnr_cpu", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_CPU", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.cpu },
            { id = "ci_deploy_cntnr_htmltopdf_qa_cntnr_mem_res", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.memory },
            { id = "ci_deploy_cntnr_htmltopdf_qa_cntnr_port", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_PORT", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.port },
            { id = "ci_deploy_cntnr_htmltopdf_qa_cluster_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CLUSTER_NAME", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.compute.cluster_name },
            { id = "ci_deploy_cntnr_htmltopdf_qa_svc_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "SERVICE_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.service_name },

            { id = "ci_deploy_cntnr_htmltopdf_qa_log_driver", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_DRIVER", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.driver },
            { id = "ci_deploy_cntnr_htmltopdf_qa_log_group", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_GROUP", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.group },
            { id = "ci_deploy_cntnr_htmltopdf_qa_log_prefix", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_PREFIX", value = data.terraform_remote_state.qa_platform.outputs.qa.platform.logs.logging.prefix },

            { id = "ci_deploy_cntnr_htmltopdf_qa_port_mapping_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.port_mapping_name },
            { id = "ci_deploy_cntnr_htmltopdf_qa_network_mode", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "NETWORK_MODE", value = data.terraform_remote_state.qa_api.outputs.qa.htmltopdf.api.container.network_mode },
          ]

          test = [
            { id = "ci_deploy_cntnr_htmltopdf_test_task_fam", path = local.paths.ci.deploy.container.htmltopdf.test, key = "TASK_FAMILY", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.task_definition_family },
            { id = "ci_deploy_cntnr_htmltopdf_test_task_role_arn", path = local.paths.ci.deploy.container.htmltopdf.test, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.task_role_arn },
            { id = "ci_deploy_cntnr_htmltopdf_test_cntnr_name", path = local.paths.ci.deploy.container.htmltopdf.test, key = "CONTAINER_NAME", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.container_name },
            { id = "ci_deploy_cntnr_htmltopdf_test_cntnr_cpu", path = local.paths.ci.deploy.container.htmltopdf.test, key = "CONTAINER_CPU", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.cpu },
            { id = "ci_deploy_cntnr_htmltopdf_test_cntnr_mem_res", path = local.paths.ci.deploy.container.htmltopdf.test, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.memory },
            { id = "ci_deploy_cntnr_htmltopdf_test_cntnr_port", path = local.paths.ci.deploy.container.htmltopdf.test, key = "CONTAINER_PORT", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.port },
            { id = "ci_deploy_cntnr_htmltopdf_test_cluster_name", path = local.paths.ci.deploy.container.htmltopdf.test, key = "CLUSTER_NAME", value = data.terraform_remote_state.test_platform.outputs.test.platform.compute.htmltopdf.cluster_name },
            { id = "ci_deploy_cntnr_htmltopdf_test_svc_name", path = local.paths.ci.deploy.container.htmltopdf.test, key = "SERVICE_NAME", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.service_name },

            { id = "ci_deploy_cntnr_htmltopdf_test_log_driver", path = local.paths.ci.deploy.container.htmltopdf.test, key = "LOG_DRIVER", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.driver },
            { id = "ci_deploy_cntnr_htmltopdf_test_log_group", path = local.paths.ci.deploy.container.htmltopdf.test, key = "LOG_GROUP", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.group },
            { id = "ci_deploy_cntnr_htmltopdf_test_log_prefix", path = local.paths.ci.deploy.container.htmltopdf.test, key = "LOG_PREFIX", value = data.terraform_remote_state.test_platform.outputs.test.platform.logs.logging.prefix },

            { id = "ci_deploy_cntnr_htmltopdf_test_port_mapping_name", path = local.paths.ci.deploy.container.htmltopdf.test, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.port_mapping_name },
            { id = "ci_deploy_cntnr_htmltopdf_test_network_mode", path = local.paths.ci.deploy.container.htmltopdf.test, key = "NETWORK_MODE", value = data.terraform_remote_state.test_htmltopdf.outputs.test.htmltopdf.api.container.network_mode },
          ]
        }
      }

      db = {
        api = {
          qa = [
            { id = "ci_deploy_db_api_qa_username", path = local.paths.ci.deploy.db.api.qa, key = "DB_USERNAME", value = local.qa_secrets.db.username },
            { id = "ci_deploy_db_api_qa_password", path = local.paths.ci.deploy.db.api.qa, key = "DB_PASSWORD", value = local.qa_secrets.db.password },
          ]

          test = [
            { id = "ci_deploy_db_api_test_username", path = local.paths.ci.deploy.db.api.test, key = "DB_USERNAME", value = local.test_secrets.db.username },
            { id = "ci_deploy_db_api_test_password", path = local.paths.ci.deploy.db.api.test, key = "DB_PASSWORD", value = local.test_secrets.db.password },
          ]
        }
      }

      website = {
        storybook = {
          qa = [
            { id = "ci_deploy_website_storybook_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.storybook.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa_www.outputs.qa.storybook.www.host.id },
            { id = "ci_deploy_website_storybook_qa_cdn_id", path = local.paths.ci.deploy.website.storybook.qa, key = "CDN_ID", value = local.cdn.storybook },
          ]
        }

        www = {
          qa = [
            { id = "ci_deploy_website_www_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.www.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa_www.outputs.qa.www.www.host.id },
            { id = "ci_deploy_website_www_qa_cdn_id", path = local.paths.ci.deploy.website.www.qa, key = "CDN_ID", value = local.cdn.www },
          ]
        }

        portal = {
          qa = [
            { id = "ci_deploy_website_portal_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.portal.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa_www.outputs.qa.portal.www.host.id },
            { id = "ci_deploy_website_portal_qa_cdn_id", path = local.paths.ci.deploy.website.portal.qa, key = "CDN_ID", value = local.cdn.portal },
          ]
        }

        console = {
          qa = [
            { id = "ci_deploy_website_console_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.console.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa_www.outputs.qa.console.www.host.id },
            { id = "ci_deploy_website_console_qa_cdn_id", path = local.paths.ci.deploy.website.console.qa, key = "CDN_ID", value = local.cdn.console },
          ]
        }

        registration = {
          qa = [
            { id = "ci_deploy_website_registration_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.registration.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa_www.outputs.qa.registration.www.host.id },
            { id = "ci_deploy_website_registration_qa_cdn_id", path = local.paths.ci.deploy.website.registration.qa, key = "CDN_ID", value = local.cdn.registration },
          ]
        }
      }
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  ci_output = {
    shared_env_vars = [
      { key = "AWS_REGION", value = var.client_info.region },
      { key = "CI_FOLDER", value = "./ci" },
      { key = "DEV_TOOLS_STORE_SCRIPTS", value = "s3://${data.terraform_remote_state.dev_tools_store.outputs.id}" },
      { key = "LOAD_ENV_VARS_SCRIPT", value = data.terraform_remote_state.ci_scripts.outputs.scripts.load_env_vars.key },
      { key = "ENV_FILE_STORE_LOCATION", value = data.terraform_remote_state.qa_cloud.outputs.qa.cloud.storage.id },
      { key = "ENV_FILE_NAME", value = "${var.client_info.project_short_name}-${var.client_info.service_short_name}.env" },
      { key = "CERT_STORE", value = "s3://${data.terraform_remote_state.qa_cloud.outputs.qa.cloud.storage.id}" },
      { key = "CERT_NAME", value = data.terraform_remote_state.qa_platform.outputs.qa.db_certs["oph-db-qa"].key },
      { key = "POST_BUILD_SCRIPT_KEY", value = data.terraform_remote_state.ci_scripts.outputs.scripts.post_build.key },
    ]
  }
}
