#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/cloud/test/terraform.tfstate"
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

locals {
  name = "${var.client_info.project_short_name}-${var.client_info.service_short_name}-${var.client_info.environment_short_name}"

  ports = {
    api      = 7890
    database = 5432
  }
}

module "test" {
  source = "../../../../module/implementation/cloud"

  cloud = {
    run = var.run

    name   = local.name
    region = var.client_info.region

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
        { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = local.ports.api },
      ]
    }
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "test" {
  value = {
    ports = local.ports
    cloud = module.test.cloud
  }
}
