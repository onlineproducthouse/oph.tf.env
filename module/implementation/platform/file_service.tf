#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "file_service" {
  source = "../../interface/aws/storage/s3/bucket"
  bucket = {
    name = "${var.platform.name}-fs"
  }
}

module "versioning" {
  source = "../../interface/aws/storage/s3/bucket/versioning"
  versioning = {
    bucket_id = module.file_service.id
  }
}

module "encryption" {
  source = "../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  encryption_configuration = {
    bucket_id = module.file_service.id
  }
}

module "cors" {
  source = "../../interface/aws/storage/s3/bucket/cors_configuration"
  cors_configuration = {
    bucket_id = module.file_service.id
    rules     = var.platform.fs_cors_rules
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  file_service_output = {
    id  = module.file_service.id
    arn = module.file_service.arn
  }
}
