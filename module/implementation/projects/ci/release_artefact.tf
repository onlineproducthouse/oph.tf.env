#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "release_artefact" {
  source = "../../../interface/aws/storage/s3/bucket"

  for_each = {
    for i, build_job in var.ci.jobs.build : build_job.branch_name => build_job
  }

  bucket = {
    name = "${var.ci.name}-${each.value.branch_name}-release-artefacts"
  }
}

module "release_artefact_versioning" {
  source = "../../../interface/aws/storage/s3/bucket/versioning"

  for_each = {
    for i, build_job in var.ci.jobs.build : build_job.branch_name => build_job
  }

  versioning = {
    bucket_id = module.release_artefact[each.value.branch_name].id
  }
}

module "release_artefact_encryption" {
  source = "../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"

  for_each = {
    for i, build_job in var.ci.jobs.build : build_job.branch_name => build_job
  }

  encryption_configuration = {
    bucket_id = module.release_artefact[each.value.branch_name].id
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

# locals {
#   release_artefact_output = {
#     for i, build_job in var.ci.jobs.build : build_job.branch_name => module.release_artefact[build_job.branch_name].id
#   }
# }
