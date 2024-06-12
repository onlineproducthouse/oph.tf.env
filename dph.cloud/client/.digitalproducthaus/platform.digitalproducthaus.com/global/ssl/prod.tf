#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################


#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "api_prod" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  client_info = var.client_info

  certificate = {
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    domain_name    = "api.${data.terraform_remote_state.dns.outputs.dns.domain_name}"
  }
}

module "web_prod" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  client_info = {
    region             = "us-east-1"
    owner              = "1702tech"
    project_name       = "digitalproducthaus"
    project_short_name = "dph"
    service_name       = "platform"
    environment_name   = "global"
  }

  certificate = {
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    domain_name    = data.terraform_remote_state.dns.outputs.dns.domain_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "prod" {
  value = {
    api = module.api_prod
    web = module.web_prod
  }
}
