#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/services/htmltopdf/qa/terraform.tfstate"
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
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "cloud" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/cloud/qa/terraform.tfstate"
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
  run = var.run == true && data.terraform_remote_state.cloud.outputs.qa.cloud.run == true && data.terraform_remote_state.platform.outputs.qa.platform.run == true

  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  aws_autoscaling_group = {
    name = data.terraform_remote_state.platform.outputs.qa.platform.compute.htmltopdf.auto_scaling_group.name
  }

  batch = [
    {
      run = local.run

      region                = var.client_info.region
      name                  = "htmltopdf-${var.client_info.environment_short_name}"
      vpc_id                = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      aws_autoscaling_group = local.aws_autoscaling_group

      container = {
        name         = "${local.name}-htmltopdf-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.qa.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.qa.platform.compute.htmltopdf.cluster_id

        cpu    = 1800
        memory = 800

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 100
        deployment_maximum_healthy_percent = 200

        logging = data.terraform_remote_state.platform.outputs.qa.platform.logs.logging
      }
    },
  ]
}

module "qa" {
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

output "qa" {
  value = {
    run       = local.run
    htmltopdf = module.qa["htmltopdf-${var.client_info.environment_short_name}"]
  }
}
