#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/qa/terraform.tfstate"
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

  dns = {
    domain_name    = data.terraform_remote_state.dns.outputs.dns.domain_name
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  }
}

module "qa" {
  source = "../../../../../../module/implementation/platform"

  platform = {
    run = var.run

    name   = local.name
    region = var.client_info.region

    dns = {
      hosted_zone_id = local.dns.hosted_zone_id
    }

    ssl = [
      {
        key         = "api",
        region      = var.client_info.region
        domain_name = "api.qa.${local.dns.domain_name}"
      },
      {
        key         = "www",
        region      = "us-east-1"
        domain_name = "qa.${local.dns.domain_name}"
      },
    ]

    cloud = {
      vpc_id                 = data.terraform_remote_state.cloud.outputs.qa.cloud.network.vpc.id
      private_subnet_id_list = data.terraform_remote_state.cloud.outputs.qa.cloud.network.subnet_id_list.private
    }

    logs = {
      group = "${local.name}-log-group"
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
}

locals {
  key_prefix = "${var.client_info.project_short_name}/${var.client_info.service_name}"
  db_certs = [
    { key = "oph-db-qa" },
  ]
}

module "db_certs" {
  source = "../../../../../../module/interface/aws/storage/s3/bucket/object"

  for_each = {
    for index, cert in local.db_certs : cert.key => cert
  }

  object = {
    bucket_id   = module.qa.platform.storage.id
    key         = "/${local.key_prefix}/${each.value.key}.crt"
    source_path = "./content/${each.value.key}.crt"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "qa" {
  value = {
    run      = var.run
    platform = module.qa.platform
    db_certs = module.db_certs
  }
}
