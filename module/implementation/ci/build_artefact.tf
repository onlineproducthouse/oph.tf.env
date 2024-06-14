#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "build_artefact" {
  source = "../../../module/implementation/shared/storage"

  storage = {
    bucket_name = "${var.ci.name}-build-artefacts"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  build_artefact_output = {
    id = module.build_artefact.id
  }
}
