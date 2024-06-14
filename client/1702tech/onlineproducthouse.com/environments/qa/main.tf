#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/environments/qa/terraform.tfstate"
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
  type    = bool
  default = false
}

variable "client_info" {
  type = object({
    region = string

    owner_name       = string
    owner_short_name = string

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

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/shared/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "ssl" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/onlineproducthouse.com/shared/ssl/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  name = "${var.client_info.owner_short_name}-${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  api_port           = 7890
  api_htmltopdf_port = 7891
  health_check_path  = "/HealthCheck/Ping"

  container = {
    network_mode                       = "host"
    launch_type                        = "EC2"
    cpu                                = 1400
    memory                             = 650
    desired_tasks_count                = 1
    deployment_minimum_healthy_percent = 100
    deployment_maximum_healthy_percent = 200
  }

  host = {
    index_page = "index.html"
    error_page = "index.html"
  }
}

module "qa" {
  source = "../../../../../module/implementation/environment"

  environment = {
    run = var.run

    name         = local.name
    region       = var.client_info.region
    owner_name   = var.client_info.owner_short_name
    project_name = var.client_info.project_short_name
    service_name = var.client_info.service_short_name

    storage = {
      db_cert_key         = "/${var.client_info.owner}/${var.client_info.project_short_name}/${var.client_info.service_name}/root.crt"
      db_cert_source_path = "./content/root.crt"
    }

    logs = {
      group = local.name
    }

    network = {
      availibility_zones = ["eu-west-1a", "eu-west-1b"]

      cidr_blocks = {
        vpc    = "10.0.0.0/16"
        public = "0.0.0.0/0"

        subnets = {
          private = ["10.0.50.0/24", "10.0.51.0/24"]
          public  = ["10.0.0.0/24", "10.0.1.0/24"]
        }
      }
    }

    load_balancer = {
      security_group_rules = [
        { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], port = 0 },
        { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = local.api_port },
        { name = "api-htmltopdf", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = local.api_htmltopdf_port },
      ]
    }

    compute = {
      enable_container_insights = false
      target_capacity           = 100

      instance = {
        image_id      = "ami-0ef8272297113026d"
        instance_type = "t3a.micro"
      }

      auto_scaling = {
        minimum = 1
        maximum = 1
        desired = 1
      }

      security_group_rules = [
        { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], from_port = 0, to_port = 0 },
        { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], from_port = local.api_port, to_port = local.api_port },
        { name = "api-htmltopdf", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], from_port = local.api_htmltopdf_port, to_port = local.api_htmltopdf_port },
      ]
    }
  }

  api = [
    {
      name      = "api"
      port      = local.api_port
      container = local.container

      load_balancer = {
        health_check_path = "/api${local.health_check_path}"

        hosted_zone = {
          id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
        }

        listener = {
          certificate = {
            arn         = data.terraform_remote_state.ssl.outputs.qa.api.cert_arn
            domain_name = "${var.client_info.project_short_name}.${data.terraform_remote_state.ssl.outputs.qa.api.cert_domain_name}"
          }
        }
      }
    },
    {
      name      = "htmltopdf"
      port      = local.api_htmltopdf_port
      container = local.container

      load_balancer = {
        health_check_path = local.health_check_path

        hosted_zone = {
          id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
        }

        listener = {
          certificate = {
            arn         = data.terraform_remote_state.ssl.outputs.qa.api.cert_arn
            domain_name = "htmltopdf.${data.terraform_remote_state.ssl.outputs.qa.api.cert_domain_name}"
          }
        }
      }
    },
  ]

  web = [
    {
      name = "storybook"
      host = local.host

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.ssl.outputs.qa.web.cert_arn
          domain_name = "storybook.${data.terraform_remote_state.ssl.outputs.qa.web.cert_domain_name}"
        }
      }
    },
    {
      name = "www"
      host = local.host

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.ssl.outputs.qa.web.cert_arn
          domain_name = "www.${data.terraform_remote_state.ssl.outputs.qa.web.cert_domain_name}"
        }
      }
    },
    {
      name = "portal"
      host = local.host

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.ssl.outputs.qa.web.cert_arn
          domain_name = "portal.${data.terraform_remote_state.ssl.outputs.qa.web.cert_domain_name}"
        }
      }
    },
    {
      name = "console"
      host = local.host

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.ssl.outputs.qa.web.cert_arn
          domain_name = "console.${data.terraform_remote_state.ssl.outputs.qa.web.cert_domain_name}"
        }
      }
    },
  ]
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "qa" {
  value = {
    run         = var.run
    environment = module.qa.environment
    api         = module.qa.api
    web         = module.qa.web
  }
}
