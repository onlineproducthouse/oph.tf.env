#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/services/api/qa/terraform.tfstate"
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

  health_check_path = "/api/HealthCheck/Ping"

  aws_autoscaling_group = {
    name = data.terraform_remote_state.platform.outputs.qa.platform.compute.auto_scaling_group.name
  }

  hosted_zone = {
    id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  }

  api = [
    {
      run = local.run

      region                = var.client_info.region
      name                  = "api-${var.client_info.environment_short_name}"
      vpc_id                = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      port                  = data.terraform_remote_state.cloud.outputs.qa.ports.api
      aws_autoscaling_group = local.aws_autoscaling_group

      load_balancer = {
        arn                      = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.arn
        health_check_path        = local.health_check_path
        listener_certificate_arn = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_arn
        domain_name              = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name
      }

      container = {
        name         = "${local.name}-api-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.qa.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.qa.platform.compute.cluster_id

        cpu    = 900
        memory = 450

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 0
        deployment_maximum_healthy_percent = 100

        logging = data.terraform_remote_state.platform.outputs.qa.platform.logs.logging
      }
    },
    {
      run = local.run

      region                = var.client_info.region
      name                  = "htmltopdf-${var.client_info.environment_short_name}"
      vpc_id                = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      port                  = data.terraform_remote_state.cloud.outputs.qa.ports.htmltopdf
      aws_autoscaling_group = local.aws_autoscaling_group

      load_balancer = {
        arn                      = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.arn
        health_check_path        = local.health_check_path
        listener_certificate_arn = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_arn
        domain_name              = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name
      }

      container = {
        name         = "${local.name}-htmltopdf-cntnr"
        role_arn     = data.terraform_remote_state.platform.outputs.qa.platform.role.arn
        network_mode = "host"
        launch_type  = "EC2"
        cluster_id   = data.terraform_remote_state.platform.outputs.qa.platform.compute.cluster_id

        cpu    = 900
        memory = 450

        desired_tasks_count                = 1
        deployment_minimum_healthy_percent = 0
        deployment_maximum_healthy_percent = 100

        logging = data.terraform_remote_state.platform.outputs.qa.platform.logs.logging
      }
    },
  ]
}

resource "aws_route53_record" "domain_name" {
  count = local.run == true ? 1 : 0

  zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  name    = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.dns_name
    zone_id                = data.terraform_remote_state.cloud.outputs.qa.cloud.load_balancer.zone_id
    evaluate_target_health = true
  }
}

module "qa" {
  source = "../../../../../../../../module/implementation/projects/api"

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
    run         = local.run
    api         = module.qa["api-${var.client_info.environment_short_name}"]
    htmltopdf   = module.qa["htmltopdf-${var.client_info.environment_short_name}"]
    domain_name = data.terraform_remote_state.platform.outputs.qa.ssl.api.cert_domain_name
  }
}
