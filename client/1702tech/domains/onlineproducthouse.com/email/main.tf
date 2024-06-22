#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/domains/onlineproducthouse.com/email/terraform.tfstate"
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

variable "sg_sender_auth" {
  description = "Configuration for authenticating email address used in SendGrid"

  type = list(object({
    type  = string
    host  = string
    value = string
  }))

  default = []
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

module "sender_auth" {
  source = "../../../../../module/interface/aws/networking/route53/hosted_zone/dns_record"

  for_each = {
    for index, record in var.sg_sender_auth : record.host => record
  }

  record = {
    zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    name    = each.value.host
    type    = each.value.type

    ttl     = "60"
    records = [each.value.value]

    with_alias             = false
    alias_zone_id          = ""
    alias_name             = ""
    evaluate_target_health = false
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "do_not_reply" {
  value = "do-not-reply@${data.terraform_remote_state.dns.outputs.dns.domain_name}"
}
