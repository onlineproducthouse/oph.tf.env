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

module "api_qa" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  certificate = {
    region         = var.client_info.region
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    domain_name    = "api.qa.${data.terraform_remote_state.dns.outputs.dns.domain_name}"
  }
}

module "web_qa" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  certificate = {
    region         = "us-east-1"
    hosted_zone_id = data.terraform_remote_state.dns.outputs.dns.hosted_zone_id
    domain_name    = "qa.${data.terraform_remote_state.dns.outputs.dns.domain_name}"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "qa" {
  value = {
    api = module.api_qa
    web = module.web_qa
  }
}
