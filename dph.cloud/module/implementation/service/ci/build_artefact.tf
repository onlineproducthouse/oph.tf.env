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

module "build_artefact" {
  source = "../../../../module/implementation/shared/storage/private_s3_bucket"

  count = var.config_switch.build_artefact == true ? 1 : 0

  bucket_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-build-artefacts"
  client_info = var.client_info
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "build_artefact" {
  value = module.build_artefact[0]
}
