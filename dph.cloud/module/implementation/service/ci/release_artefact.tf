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

module "release_artefact" {
  source = "../../../../module/implementation/shared/storage/private_s3_bucket"

  bucket_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-release-artefacts"
  client_info = var.client_info
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################
