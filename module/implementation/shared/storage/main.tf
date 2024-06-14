#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "storage" {
  type = object({
    bucket_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "storage" {
  source = "../../../interface/aws/storage/s3/bucket"
  bucket = {
    name = var.storage.bucket_name
  }
}

module "versioning" {
  source = "../../../interface/aws/storage/s3/bucket/versioning"
  versioning = {
    bucket_id = module.storage.id
  }
}

module "encryption" {
  source = "../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  encryption_configuration = {
    bucket_id = module.storage.id
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "id" {
  value = module.storage.id
}

output "arn" {
  value = module.storage.arn
}
