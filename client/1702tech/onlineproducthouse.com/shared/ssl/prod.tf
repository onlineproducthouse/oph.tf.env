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

  certificate = {
    region         = var.client_info.region
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    domain_name    = "api.${data.terraform_remote_state.dns.outputs.dns.domain_name}"
  }
}

module "web_prod" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  certificate = {
    region         = "us-east-1"
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
