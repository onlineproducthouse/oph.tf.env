#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################
# data.terraform_remote_state.qa.outputs.qa

data "terraform_remote_state" "oph_dev_tools_store" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/storage/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "oph_ci_scripts" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
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
        storybook = []
        www       = []
        portal    = []
        console   = []
      }
    }

    deploy = {
      container = {
        api = {
          qa = [
            { id = "ci_deploy_container_api_qa_task_fam", path = local.paths.ci.deploy.container.api.qa, key = "TASK_FAMILY", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.task_definition_family },
            { id = "ci_deploy_container_api_qa_task_role_arn", path = local.paths.ci.deploy.container.api.qa, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.task_role_arn },
            { id = "ci_deploy_container_api_qa_container_name", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.container_name },
            { id = "ci_deploy_container_api_qa_container_cpu", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_CPU", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.cpu },
            { id = "ci_deploy_container_api_qa_container_mem_res", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.memory },
            { id = "ci_deploy_container_api_qa_container_port", path = local.paths.ci.deploy.container.api.qa, key = "CONTAINER_PORT", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.port },
            { id = "ci_deploy_container_api_qa_cluster_name", path = local.paths.ci.deploy.container.api.qa, key = "CLUSTER_NAME", value = data.terraform_remote_state.qa.outputs.qa.environment.compute.cluster_name },
            { id = "ci_deploy_container_api_qa_svc_name", path = local.paths.ci.deploy.container.api.qa, key = "SERVICE_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.service_name },

            { id = "ci_deploy_container_api_qa_log_driver", path = local.paths.ci.deploy.container.api.qa, key = "LOG_DRIVER", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.logging.driver },
            { id = "ci_deploy_container_api_qa_log_group", path = local.paths.ci.deploy.container.api.qa, key = "LOG_GROUP", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.logging.group },
            { id = "ci_deploy_container_api_qa_log_prefix", path = local.paths.ci.deploy.container.api.qa, key = "LOG_PREFIX", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.logging.prefix },

            { id = "ci_deploy_container_api_qa_port_mapping_name", path = local.paths.ci.deploy.container.api.qa, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.port_mapping_name },
            { id = "ci_deploy_container_api_qa_network_mode", path = local.paths.ci.deploy.container.api.qa, key = "NETWORK_MODE", value = data.terraform_remote_state.qa.outputs.qa.api.api.container.network_mode },
          ]
        }

        htmltopdf = {
          qa = [
            { id = "ci_deploy_container_htmltopdf_qa_task_fam", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "TASK_FAMILY", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.task_definition_family },
            { id = "ci_deploy_container_htmltopdf_qa_task_role_arn", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "TASK_ROLE_ARN", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.task_role_arn },
            { id = "ci_deploy_container_htmltopdf_qa_container_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.container_name },
            { id = "ci_deploy_container_htmltopdf_qa_container_cpu", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_CPU", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.cpu },
            { id = "ci_deploy_container_htmltopdf_qa_container_mem_res", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_MEMORY_RESERVATION", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.memory },
            { id = "ci_deploy_container_htmltopdf_qa_container_port", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CONTAINER_PORT", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.port },
            { id = "ci_deploy_container_htmltopdf_qa_cluster_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "CLUSTER_NAME", value = data.terraform_remote_state.qa.outputs.qa.environment.compute.cluster_name },
            { id = "ci_deploy_container_htmltopdf_qa_svc_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "SERVICE_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.service_name },

            { id = "ci_deploy_container_htmltopdf_qa_log_driver", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_DRIVER", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.logging.driver },
            { id = "ci_deploy_container_htmltopdf_qa_log_group", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_GROUP", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.logging.group },
            { id = "ci_deploy_container_htmltopdf_qa_log_prefix", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "LOG_PREFIX", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.logging.prefix },

            { id = "ci_deploy_container_htmltopdf_qa_port_mapping_name", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "PORT_MAPPING_NAME", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.port_mapping_name },
            { id = "ci_deploy_container_htmltopdf_qa_network_mode", path = local.paths.ci.deploy.container.htmltopdf.qa, key = "NETWORK_MODE", value = data.terraform_remote_state.qa.outputs.qa.api.htmltopdf.container.network_mode },
          ]
        }
      }

      db = {
        api = {
          qa = [
            { id = "ci_deploy_db_api_qa_username", path = local.paths.ci.deploy.db.api.qa, key = "DB_SUPER_USERNAME", value = local.secrets.qa.db.username },
            { id = "ci_deploy_db_api_qa_password", path = local.paths.ci.deploy.db.api.qa, key = "DB_SUPER_PASSWORD", value = local.secrets.qa.db.password },
          ]
        }
      }

      website = {
        storybook = {
          qa = [
            { id = "ci_deploy_website_storybook_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.storybook.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa.outputs.web.storybook.host.id },
            { id = "ci_deploy_website_storybook_qa_cdn_id", path = local.paths.ci.deploy.website.storybook.qa, key = "CDN_ID", value = data.terraform_remote_state.qa.outputs.web.storybook.cdn.id },
          ]
        }

        www = {
          qa = [
            { id = "ci_deploy_website_www_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.www.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa.outputs.web.www.host.id },
            { id = "ci_deploy_website_www_qa_cdn_id", path = local.paths.ci.deploy.website.www.qa, key = "CDN_ID", value = data.terraform_remote_state.qa.outputs.web.www.cdn.id },
          ]
        }

        portal = {
          qa = [
            { id = "ci_deploy_website_portal_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.portal.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa.outputs.web.portal.host.id },
            { id = "ci_deploy_website_portal_qa_cdn_id", path = local.paths.ci.deploy.website.portal.qa, key = "CDN_ID", value = data.terraform_remote_state.qa.outputs.web.portal.cdn.id },
          ]
        }

        console = {
          qa = [
            { id = "ci_deploy_website_console_qa_s3_host_bucket_url", path = local.paths.ci.deploy.website.console.qa, key = "S3_HOST_BUCKET_URL", value = data.terraform_remote_state.qa.outputs.web.console.host.id },
            { id = "ci_deploy_website_console_qa_cdn_id", path = local.paths.ci.deploy.website.console.qa, key = "CDN_ID", value = data.terraform_remote_state.qa.outputs.web.console.cdn.id },
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
      { key = "DEV_TOOLS_STORE_SCRIPTS", value = "s3://${data.terraform_remote_state.oph_dev_tools_store.outputs.id}" },
      { key = "LOAD_ENV_VARS_SCRIPT", value = data.terraform_remote_state.oph_ci_scripts.outputs.scripts.load_env_vars.key },
      { key = "ENV_FILE_STORE_LOCATION", value = data.terraform_remote_state.qa.outputs.qa.storage.storage.id },
      { key = "ENV_FILE_NAME", value = "${var.client_info.project_short_name}-${var.client_info.service_short_name}.env" },
      { key = "CERT_STORE", value = "s3://${data.terraform_remote_state.qa.outputs.qa.storage.storage.id}" },
      { key = "CERT_NAME", value = data.terraform_remote_state.qa.outputs.qa.storage.db_cert.key },
      { key = "POST_BUILD_SCRIPT_KEY", value = data.terraform_remote_state.oph_ci_scripts.outputs.scripts.post_build.key },
    ]
  }
}
