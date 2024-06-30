#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/developer_tools/scripts/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  scripts = [
    { name = "assume_role", key = "/oph/scripts/assume-role.sh", source_path = "./scripts/assume-role.sh" },
    { name = "build_client", key = "/oph/scripts/build-client.sh", source_path = "./scripts/build-client.sh" },
    { name = "build_container", key = "/oph/scripts/build-container.sh", source_path = "./scripts/build-container.sh" },
    { name = "codebuild_job", key = "/oph/scripts/codebuild.job.yml", source_path = "./scripts/codebuild.job.yml" },
    { name = "deploy_client", key = "/oph/scripts/deploy-client.sh", source_path = "./scripts/deploy-client.sh" },
    { name = "deploy_container", key = "/oph/scripts/deploy-container.sh", source_path = "./scripts/deploy-container.sh" },
    { name = "import_docker_image", key = "/oph/scripts/import-docker-image.sh", source_path = "./scripts/import-docker-image.sh" },
    { name = "load_env_vars", key = "/oph/scripts/load-env-vars.sh", source_path = "./scripts/load-env-vars.sh" },
    { name = "local_env_vars", key = "/oph/scripts/local-env-vars.sh", source_path = "./scripts/local-env-vars.sh" },
    { name = "migrate_db", key = "/oph/scripts/migrate-db.sh", source_path = "./scripts/migrate-db.sh" },
    { name = "post_build", key = "/oph/scripts/post-build.sh", source_path = "./scripts/post-build.sh" },
    { name = "product_platform_state", key = "/oph/scripts/product.platform.state.sh", source_path = "./scripts/product.platform.state.sh" },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "scripts" {
  value = {
    for script in local.scripts : script.name => {
      key            = script.key,
      name           = script.name,
      etag           = filemd5(script.source_path),
      content_base64 = filebase64(script.source_path),
    }
  }
}
