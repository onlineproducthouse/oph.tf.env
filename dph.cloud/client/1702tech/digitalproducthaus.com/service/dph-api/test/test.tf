#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/service/dph-api/test/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                      VERSIONS                     #
#                                                   #
#####################################################

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      version = "4.8.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.client_info.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "vpc_in_use" {
  type    = bool
  default = false
}

variable "vpc_cidr_block" {
  type    = string
  default = "" // leave empty to disable else set to, e.g. 10.0.0.0/16
}

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "networking" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/networking/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "acm_certs" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "client/1702tech/digitalproducthaus.com/global/ssl/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  vpc_in_use         = var.vpc_in_use
  vpc_cidr_block     = var.vpc_cidr_block
  availibility_zones = ["eu-west-1b", "eu-west-1c"]
}

locals {
  content = {
    db_cert_source_path = "./content/db-cert-test.crt"
  }

  api = {
    port = 10000
    compute = {
      auto_scaling_group = {
        desired_instances = 1
        max_instances     = 1
        min_instances     = 1
      }
      launch_configuration = {
        image_id      = "ami-027078d981e5d4010"
        instance_type = "t3a.micro"
      }
    }

    load_balancer = {
      domain_name_prefix = var.client_info.project_short_name
      hosted_zone = {
        id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      }
      listener = {
        certificate = {
          arn         = data.terraform_remote_state.acm_certs.outputs.test.api.cert_arn
          domain_name = data.terraform_remote_state.acm_certs.outputs.test.api.cert_domain_name
        }
      }
    }

    network = {
      vpc_in_use      = local.vpc_in_use
      vpc_cidr_block  = local.vpc_cidr_block
      dest_cidr_block = "0.0.0.0/0"

      subnets = {
        private = {
          availibility_zones = local.availibility_zones
          cidr_block         = ["10.0.50.0/24", "10.0.51.0/24"]
        }

        public = {
          availibility_zones = local.availibility_zones
          cidr_block         = ["10.0.0.0/24", "10.0.1.0/24"]
        }
      }
    }
  }

  web = [{
    name = "storybook"

    host = {
      vpc_in_use = local.vpc_in_use
      error_page = "index.html"
      index_page = "index.html"
    }

    cdn = {
      hosted_zone_id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      certificate = {
        arn         = data.terraform_remote_state.acm_certs.outputs.test.web.cert_arn
        domain_name = "storybook.${data.terraform_remote_state.acm_certs.outputs.test.web.cert_domain_name}"
      }
    }
    }, {
    name = "www"

    host = {
      vpc_in_use = local.vpc_in_use
      error_page = "index.html"
      index_page = "index.html"
    }

    cdn = {
      hosted_zone_id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      certificate = {
        arn         = data.terraform_remote_state.acm_certs.outputs.test.web.cert_arn
        domain_name = "www.${data.terraform_remote_state.acm_certs.outputs.test.web.cert_domain_name}"
      }
    }
    }, {
    name = "portal"

    host = {
      vpc_in_use = local.vpc_in_use
      error_page = "index.html"
      index_page = "index.html"
    }

    cdn = {
      hosted_zone_id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      certificate = {
        arn         = data.terraform_remote_state.acm_certs.outputs.test.web.cert_arn
        domain_name = "portal.${data.terraform_remote_state.acm_certs.outputs.test.web.cert_domain_name}"
      }
    }
    }, {
    name = "console"

    host = {
      vpc_in_use = local.vpc_in_use
      error_page = "index.html"
      index_page = "index.html"
    }

    cdn = {
      hosted_zone_id = data.terraform_remote_state.networking.outputs.dns.hosted_zone_id
      certificate = {
        arn         = data.terraform_remote_state.acm_certs.outputs.test.web.cert_arn
        domain_name = "console.${data.terraform_remote_state.acm_certs.outputs.test.web.cert_domain_name}"
      }
    }
  }]
}

module "test" {
  source = "../../../../../../module/implementation/service/env"

  client_info = var.client_info
  content     = local.content
  api         = local.api
  web         = local.web
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "content" {
  value = module.test.content
}

output "api" {
  value = module.test.api
}

output "web" {
  value = module.test.web
}

output "ecs" {
  value = {
    cluster_name = module.test.api.cluster.name

    task_family   = "${var.client_info.project_short_name}-${var.client_info.service_name}"
    task_role_arn = module.test.api.ecs_instance_role.id

    service_name     = "${var.client_info.project_short_name}-${var.client_info.service_name}-service"
    desired_count    = 1
    target_group_arn = module.test.api.load_balancer.target_group.arn
    log_url          = local.secrets.log_url

    container_name               = "${var.client_info.project_short_name}-${var.client_info.service_name}"
    container_cpu                = 600
    container_memory_reservation = 400
    container_port               = module.test.api.port
  }
}
