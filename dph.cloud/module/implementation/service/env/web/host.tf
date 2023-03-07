#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "host" {
  type = object({
    index_page = string
    error_page = string
  })

  default = {
    index_page = "index.html"
    error_page = "index.html"
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "host" {
  bucket = var.cdn.certificate.domain_name

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_s3_bucket_website_configuration" "host_web_config" {
  bucket = aws_s3_bucket.host.id

  index_document {
    suffix = var.host.index_page
  }

  error_document {
    key = var.host.error_page
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "host_encryption_config" {
  bucket = aws_s3_bucket.host.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_policy" "host_public_policy" {
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
  acl    = "public-read"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "host" {
  value = {
    id       = aws_s3_bucket.host.id
    endpoint = aws_s3_bucket_website_configuration.host_web_config.website_endpoint
  }
}
