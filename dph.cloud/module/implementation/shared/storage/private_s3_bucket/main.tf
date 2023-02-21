#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region           = string
    owner            = string
    project_name     = string
    service_name     = string
    environment_name = string
  })

  default = {
    region           = ""
    owner            = ""
    project_name     = ""
    service_name     = ""
    environment_name = ""
  }
}

variable "bucket_name" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "bucket" {
  source = "../../../../interface/aws/storage/s3/bucket"

  bucket_name = var.bucket_name
  client_info = var.client_info
}

module "versioning" {
  source    = "../../../../interface/aws/storage/s3/bucket/versioning"
  bucket_id = module.bucket.id
}

module "encryption" {
  source    = "../../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  bucket_id = module.bucket.id
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "id" {
  value = module.bucket.id
}

output "arn" {
  value = module.bucket.arn
}
