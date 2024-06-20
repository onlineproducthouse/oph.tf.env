#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "host" {
  bucket = var.web.cdn.certificate.domain_name
}

resource "aws_s3_bucket_website_configuration" "host" {
  bucket = aws_s3_bucket.host.id

  index_document {
    suffix = var.web.host.index_page
  }

  error_document {
    key = var.web.host.error_page
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "host" {
  bucket = aws_s3_bucket.host.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "host" {
  count = var.web.run == true ? 1 : 0

  bucket = aws_s3_bucket.host.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Id" : "MYBUCKETPOLICY",
    "Statement" : [
      {
        "Sid" : "AddPerm",
        "Effect" : "Allow",
        "Principal" : "*",
        "Action" : "s3:GetObject",
        "Resource" : "arn:aws:s3:::${aws_s3_bucket.host.id}/*"
      }
    ]
  })
}

resource "aws_s3_bucket_acl" "host_acl" {
  bucket = aws_s3_bucket.host.id
  acl    = var.web.run == true ? "public-read" : "private"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  host_output = {
    id       = aws_s3_bucket.host.id
    endpoint = aws_s3_bucket_website_configuration.host.website_endpoint
  }
}
