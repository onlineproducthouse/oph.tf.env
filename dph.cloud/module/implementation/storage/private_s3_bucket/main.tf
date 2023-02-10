#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
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
  source = "../../../interface/aws/storage/s3/bucket"

  bucket_name      = var.bucket_name
  owner            = var.owner
  environment_name = var.environment_name
}

module "versioning" {
  source    = "../../../interface/aws/storage/s3/bucket/versioning"
  bucket_id = module.bucket.id
}

module "encryption" {
  source    = "../../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
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
