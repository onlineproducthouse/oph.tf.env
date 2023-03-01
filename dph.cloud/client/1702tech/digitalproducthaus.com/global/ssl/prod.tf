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

module "prod" {
  source = "../../../../../module/interface/aws/security/acm/certificate"

  client_info = var.client_info
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
  value = module.prod
}
