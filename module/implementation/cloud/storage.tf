#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "storage" {
  source = "../../interface/aws/storage/s3/bucket"
  bucket = {
    name = "${var.cloud.name}-storage"
  }
}

module "versioning" {
  source = "../../interface/aws/storage/s3/bucket/versioning"
  versioning = {
    bucket_id = module.storage.id
  }
}

module "encryption" {
  source = "../../interface/aws/storage/s3/bucket/server_side_encryption_configuration"
  encryption_configuration = {
    bucket_id = module.storage.id
  }
}

data "aws_caller_identity" "current" {}

resource "aws_s3_bucket_policy" "access_logs" {
  bucket = module.storage.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Principal" : {
          "AWS" : "arn:aws:iam::156460612806:root"
        },
        "Action" : "s3:PutObject",
        "Resource" : "arn:aws:s3:::${module.storage.id}/${var.cloud.name}-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  storage_output = {
    id  = module.storage.id
    arn = module.storage.arn
  }
}
