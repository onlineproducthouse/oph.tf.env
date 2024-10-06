#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/api/qa/terraform.tfstate"
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
  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  api_port           = data.terraform_remote_state.cloud.outputs.qa.ports.api
  api_htmltopdf_port = data.terraform_remote_state.cloud.outputs.qa.ports.htmltopdf
  health_check_path  = "/HealthCheck/Ping"

  aws_autoscaling_group = {
    name = data.terraform_remote_state.platform.outputs.qa.platform.compute.auto_scaling_group.name
  }

  hosted_zone = {
    id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  }

  api = [
    {
      run = data.terraform_remote_state.platform.outputs.qa.run

      region = var.client_info.region
      name   = "api"
      vpc_id = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      port   = local.api_port

      aws_autoscaling_group = local.aws_autoscaling_group

      load_balancer = {
        arn               = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.arn
        health_check_path = "/api${local.health_check_path}"
        dns_name          = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.dns_name
        zone_id           = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.zone_id
        hosted_zone       = local.hosted_zone

        listener = {
          certificate = {
            arn         = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_arn
            domain_name = "api.${data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name}"
          }
        }
      }

      container = {
        name         = "${local.name}-api-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.qa.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.qa.platform.compute.cluster_id

        cpu    = 1400
        memory = 650

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 100
        deployment_maximum_healthy_percent = 200

        logging = data.terraform_remote_state.platform.outputs.qa.platform.logs.logging
      }
    },
    {
      run = data.terraform_remote_state.platform.outputs.qa.run

      region = var.client_info.region
      name   = "htmltopdf"
      vpc_id = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      port   = local.api_htmltopdf_port

      aws_autoscaling_group = local.aws_autoscaling_group

      load_balancer = {
        arn               = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.arn
        health_check_path = local.health_check_path
        dns_name          = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.dns_name
        zone_id           = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.zone_id
        hosted_zone       = local.hosted_zone

        listener = {
          certificate = {
            arn         = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_arn
            domain_name = "htmltopdf.${data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name}"
          }
        }
      }

      container = {
        name         = "${local.name}-htmltopdf-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.qa.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.qa.platform.compute.cluster_id

        cpu    = 1400
        memory = 650

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 100
        deployment_maximum_healthy_percent = 200

        logging = data.terraform_remote_state.platform.outputs.qa.platform.logs.logging
      }
    },
  ]
}

module "qa" {
  source = "../../../../../../../module/implementation/projects/api"

  for_each = {
    for index, api in local.api : api.name => api
  }

  api = each.value
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "qa" {
  value = {
    run       = data.terraform_remote_state.platform.outputs.qa.run
    api       = module.qa.api
    htmltopdf = module.qa.htmltopdf
  }
}
