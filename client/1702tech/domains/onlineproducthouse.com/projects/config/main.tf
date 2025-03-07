#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/config/terraform.tfstate"
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

data "terraform_remote_state" "git_repo_webhook" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/developer_tools/git_repo_webhook/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "email" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/email/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  paths = {
    shared = "/oph/config/shared"
    local  = "/oph/config/local"
    qa     = "/oph/config/qa"
    test   = "/oph/config/test"

    ci = {
      build = {
        container = {
          api       = "/oph/config/ci/build/container/api"
          htmltopdf = "/oph/config/ci/build/container/htmltopdf"
        }

        db = {
          api = "/oph/config/ci/build/db/api"
        }

        website = {
          storybook    = "/oph/config/ci/build/website/storybook"
          www          = "/oph/config/ci/build/website/www"
          portal       = "/oph/config/ci/build/website/portal"
          console      = "/oph/config/ci/build/website/console"
          registration = "/oph/config/ci/build/website/registration"
        }
      }

      deploy = {
        container = {
          api = {
            qa   = "/oph/config/ci/deploy/container/api/qa"
            test = "/oph/config/ci/deploy/container/api/test"
          }

          htmltopdf = {
            qa   = "/oph/config/ci/deploy/container/htmltopdf/qa"
            test = "/oph/config/ci/deploy/container/htmltopdf/test"
          }
        }

        db = {
          api = {
            qa   = "/oph/config/ci/deploy/db/api/qa"
            test = "/oph/config/ci/deploy/db/api/test"
          }
        }

        website = {
          storybook = {
            qa = "/oph/config/ci/deploy/website/storybook/qa"
          }

          www = {
            qa = "/oph/config/ci/deploy/website/www/qa"
          }

          portal = {
            qa = "/oph/config/ci/deploy/website/portal/qa"
          }

          console = {
            qa = "/oph/config/ci/deploy/website/console/qa"
          }

          registration = {
            qa = "/oph/config/ci/deploy/website/registration/qa"
          }
        }
      }
    }
  }
}

module "config" {
  source = "../../../../../../module/interface/aws/security/ssm/param_store"

  parameters = concat(
    local.shared,
    local.local,
    local.qa,
    local.test,

    local.ci.build.container.api,
    local.ci.build.container.htmltopdf,

    local.ci.build.db.api,

    local.ci.build.website.storybook,
    local.ci.build.website.www,
    local.ci.build.website.portal,
    local.ci.build.website.console,
    local.ci.build.website.registration,

    local.ci.deploy.container.api.qa,
    local.ci.deploy.container.htmltopdf.qa,

    local.ci.deploy.container.api.test,
    local.ci.deploy.container.htmltopdf.test,

    local.ci.deploy.db.api.qa,
    local.ci.deploy.db.api.test,

    local.ci.deploy.website.storybook.qa,
    local.ci.deploy.website.www.qa,
    local.ci.deploy.website.portal.qa,
    local.ci.deploy.website.console.qa,
    local.ci.deploy.website.registration.qa,
  )
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "config" {
  value = {
    paths              = local.paths
    shared_ci_env_vars = local.ci_output.shared_env_vars
    git_repo_webhook   = data.terraform_remote_state.git_repo_webhook.outputs
    email              = data.terraform_remote_state.email.outputs

    oph_dev_tools = {
      arn = data.terraform_remote_state.dev_tools_store.outputs.arn
    }

    oph_ci_scripts = {
      buildspec = data.terraform_remote_state.ci_scripts.outputs.scripts.codebuild_job.key
    }

    qa = {
      vpc_id  = data.terraform_remote_state.qa_cloud.outputs.qa.cloud.network.vpc.id
      subnets = data.terraform_remote_state.qa_cloud.outputs.qa.cloud.network.subnet.private.id_list

      is_running = {
        cloud    = data.terraform_remote_state.qa_cloud.outputs.qa.cloud.run
        platform = data.terraform_remote_state.qa_platform.outputs.qa.platform.run

        project = {
          api = data.terraform_remote_state.qa_api.outputs.qa.run
          www = data.terraform_remote_state.qa_www.outputs.qa.run
        }
      }
    }

    test = {
      vpc_id  = data.terraform_remote_state.test_cloud.outputs.test.cloud.network.vpc.id
      subnets = data.terraform_remote_state.test_cloud.outputs.test.cloud.network.subnet.private.id_list

      is_running = {
        cloud    = data.terraform_remote_state.test_cloud.outputs.test.cloud.run
        platform = data.terraform_remote_state.test_platform.outputs.test.platform.run

        project = {
          api = data.terraform_remote_state.test_api.outputs.test.run
          www = false
        }
      }
    }
  }
}
