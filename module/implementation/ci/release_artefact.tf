#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "release_artefact" {
  source = "../../../module/implementation/shared/storage"

  storage = {
    bucket_name = "${var.ci.name}-release-artefacts"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  release_artefact_output = {
    id = module.release_artefact.id
  }
}
