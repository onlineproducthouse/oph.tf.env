#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "hosted_zone_id" {
  value = module.hosted_zone.id
}

output "domain_name_servers" {
  value = module.hosted_zone.name_servers
}

output "domain_name" {
  value = var.domain_name
}

