#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/test/terraform.tfstate"
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

data "terraform_remote_state" "ssl_api" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/test/ssl/api/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "ssl_www" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/test/ssl/www/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  run = var.run == true && data.terraform_remote_state.cloud.outputs.test.cloud.run == true

  image_id = "ami-0ef8272297113026d"

  name = {
    platform = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

    compute = {
      api       = "${var.client_info.project_short_name}-api-${var.client_info.environment_short_name}"
      htmltopdf = "${var.client_info.project_short_name}-htmltopdf-${var.client_info.environment_short_name}"
    }
  }
}

module "test" {
  source = "../../../../../../module/implementation/platform"

  platform = {
    run = local.run

    name   = local.name.platform
    region = var.client_info.region

    cloud = {
      vpc_id                 = data.terraform_remote_state.cloud.outputs.test.cloud.network.vpc.id
      private_subnet_id_list = data.terraform_remote_state.cloud.outputs.test.cloud.network.subnet.private.id_list
    }

    logs = {
      group = "${local.name.platform}-log-group"
    }

    security_group_rules = [
      {
        name        = "public",
        type        = "egress",
        protocol    = "-1",
        cidr_blocks = ["0.0.0.0/0"],
        from_port   = 0,
        to_port     = 0,
      },
      {
        name        = "api",
        type        = "ingress",
        protocol    = "tcp",
        cidr_blocks = data.terraform_remote_state.cloud.outputs.test.cloud.network.subnet.public.cidr_blocks,
        from_port   = data.terraform_remote_state.cloud.outputs.test.ports.api,
        to_port     = data.terraform_remote_state.cloud.outputs.test.ports.api,
      },
      {
        name        = "database",
        type        = "ingress",
        protocol    = "tcp",
        cidr_blocks = data.terraform_remote_state.cloud.outputs.test.cloud.network.subnet.private.cidr_blocks,
        from_port   = data.terraform_remote_state.cloud.outputs.test.ports.database,
        to_port     = data.terraform_remote_state.cloud.outputs.test.ports.database,
      },
    ]

    compute = [
      {
        name          = local.name.compute.api
        image_id      = local.image_id
        instance_type = "t3a.nano"

        auto_scaling = {
          minimum = 2
          maximum = 3
          desired = 2
        }
      },
      {
        name          = local.name.compute.htmltopdf
        image_id      = local.image_id
        instance_type = "t3a.micro"

        auto_scaling = {
          minimum = 1
          maximum = 2
          desired = 1
        }
      },
    ]
  }
}

locals {
  key_prefix = "${var.client_info.project_short_name}/${var.client_info.service_name}"
  db_certs = [
    { key = "oph-db-test" },
  ]
}

module "db_certs" {
  source = "../../../../../../module/interface/aws/storage/s3/bucket/object"

  for_each = {
    for index, cert in local.db_certs : cert.key => cert
  }

  object = {
    bucket_id      = data.terraform_remote_state.cloud.outputs.test.cloud.storage.id
    key            = "/${local.key_prefix}/${each.value.key}.cert"
    source_path    = "./content/${each.value.key}.cert"
    content_base64 = null
  }
}

resource "aws_route53_record" "domain_name" {
  count = local.run == true ? 1 : 0

  zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
  name    = data.terraform_remote_state.ssl_api.outputs.certs.api.cert_domain_name
  type    = "A"

  alias {
    name                   = data.terraform_remote_state.cloud.outputs.test.cloud.load_balancer.dns_name
    zone_id                = data.terraform_remote_state.cloud.outputs.test.cloud.load_balancer.zone_id
    evaluate_target_health = true
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "test" {
  value = {
    db_certs = module.db_certs
    ssl      = merge(data.terraform_remote_state.ssl_api.outputs.certs, data.terraform_remote_state.ssl_www.outputs.certs)

    platform = {
      run          = module.test.platform.run
      file_service = module.test.platform.file_service
      role         = module.test.platform.role
      logs         = module.test.platform.logs

      compute = {
        api       = module.test.platform.compute[local.name.compute.api].compute
        htmltopdf = module.test.platform.compute[local.name.compute.htmltopdf].compute
      }
    }
  }
}
