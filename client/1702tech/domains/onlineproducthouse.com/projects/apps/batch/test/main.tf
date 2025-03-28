#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/apps/batch/test/terraform.tfstate"
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

variable "run" {
  type = bool
}

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

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "cloud" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/cloud/test/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/dns/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  run = var.run == true && data.terraform_remote_state.cloud.outputs.test.cloud.run == true && data.terraform_remote_state.platform.outputs.test.platform.run == true

  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  aws_autoscaling_group = {
    name = data.terraform_remote_state.platform.outputs.test.platform.compute.batch.auto_scaling_group.name
  }

  batch = [
    {
      run = local.run

      region = var.client_info.region
      name   = "batch-${var.client_info.environment_short_name}"
      vpc_id = data.terraform_remote_state.cloud.outputs.test.cloud.network.vpc.id

      aws_autoscaling_group = local.aws_autoscaling_group

      container = {
        name         = "${local.name}-batch-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.test.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.test.platform.compute.batch.cluster_id

        cpu    = 1600
        memory = 800

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 0
        deployment_maximum_healthy_percent = 100

        logging = data.terraform_remote_state.platform.outputs.test.platform.logs.logging
      }
    },
  ]
}

module "test" {
  source = "../../../../../../../../module/implementation/projects/batch"

  for_each = {
    for index, batch in local.batch : batch.name => batch
  }

  batch = each.value
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "test" {
  value = {
    run   = local.run
    batch = module.test["batch-${var.client_info.environment_short_name}"]
  }
}
