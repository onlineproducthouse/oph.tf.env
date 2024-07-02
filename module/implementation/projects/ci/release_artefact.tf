#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "release_artefact" {
  source = "../../../interface/aws/storage/s3/bucket"
  bucket = {
    name = "${var.ci.name}-release-artefacts"
  }
}

module "release_artefact_versioning" {
  source = "../../../interface/aws/storage/s3/bucket/versioning"
  versioning = {
    bucket_id = module.release_artefact.id
  }
}

module "release_artefact_encryption" {
  source = "../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  encryption_configuration = {
    bucket_id = module.release_artefact.id
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
