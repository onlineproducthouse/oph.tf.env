#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "hosted_zone_id" {
  value = module.hosted_zone[0].id
}

output "domain_name_servers" {
  value = module.hosted_zone[0].name_servers
}

output "domain_name" {
  value = var.domain_name
}

