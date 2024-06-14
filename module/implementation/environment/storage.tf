#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "storage" {
  source = "../../../module/implementation/shared/storage"
  storage = {
    bucket_name = "${local.shared_name}-storage"
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
        "Resource" : "arn:aws:s3:::${module.storage.id}/${local.shared_name}-lb/AWSLogs/${data.aws_caller_identity.current.account_id}/*"
      }
    ]
  })
}

module "db_cert" {
  source = "../../../module/interface/aws/storage/s3/bucket/object"

  count = var.environment.run == true ? 1 : 0

  object = {
    bucket_id   = module.storage.id
    key         = var.environment.storage.db_cert_key
    source_path = var.environment.storage.db_cert_source_path
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  storage_output = {
    storage = module.storage
    db_cert = module.db_cert[0]
  }
}
