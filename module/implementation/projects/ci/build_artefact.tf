#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "build_artefact" {
  source = "../../../interface/aws/storage/s3/bucket"
  bucket = {
    bucket_name = "${var.ci.name}-build-artefacts"
  }
}

module "build_artefact_versioning" {
  source = "../../../interface/aws/storage/s3/bucket/versioning"
  versioning = {
    bucket_id = module.build_artefact.id
  }
}

module "build_artefact_encryption" {
  source = "../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  encryption_configuration = {
    bucket_id = module.build_artefact.id
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
