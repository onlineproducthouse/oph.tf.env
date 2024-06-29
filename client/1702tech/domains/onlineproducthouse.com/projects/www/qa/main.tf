#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/projects/www/qa/terraform.tfstate"
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

data "terraform_remote_state" "dns" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/dns/terraform.tfstate"
    region = "eu-west-1"
  }
}

data "terraform_remote_state" "platform" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/platform/qa/terraform.tfstate"
    region = "eu-west-1"
  }
}

locals {
  host = {
    index_page = "index.html"
    error_page = "index.html"
  }

  www = [
    {
      name = "storybook"

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_arn
          domain_name = "storybook.${data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_domain_name}"
        }
      }
    },
    {
      name = "www"

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_arn
          domain_name = "www.${data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_domain_name}"
        }
      }
    },
    {
      name = "portal"

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_arn
          domain_name = "portal.${data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_domain_name}"
        }
      }
    },
    {
      name = "console"

      cdn = {
        hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id

        certificate = {
          arn         = data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_arn
          domain_name = "console.${data.terraform_remote_state.platform.outputs.qa.ssl.www.cert_domain_name}"
        }
      }
    },
  ]
}

module "qa" {
  source = "../../../../../../../module/implementation/projects/www"

  for_each = {
    for index, web in local.www : web.name => web
  }

  www = {
    run  = var.run
    host = local.host
    cdn  = each.value.cdn
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "qa" {
  value = {
    run       = var.run
    www       = module.qa.www
    storybook = module.qa.storybook
    portal    = module.qa.portal
    console   = module.qa.console
  }
}
