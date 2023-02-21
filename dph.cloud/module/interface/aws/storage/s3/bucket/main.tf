#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "bucket_name" {
  type    = string
  default = "UnknownS3Bucket"
}

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

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    owner            = var.client_info.owner
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
    environment_name = var.client_info.environment_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "name" {
  value = aws_s3_bucket.bucket.id
}
output "id" {
  value = aws_s3_bucket.bucket.id
}
output "arn" {
  value = aws_s3_bucket.bucket.arn
}
output "domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}
output "regional_domain_name" {
  value = aws_s3_bucket.bucket.bucket_regional_domain_name
}
output "hosted_zone_id" {
  value = aws_s3_bucket.bucket.hosted_zone_id
}
output "bucket_domain_name" {
  value = aws_s3_bucket.bucket.bucket_domain_name
}
# output "website_endpoint" {
#   value = aws_s3_bucket.bucket.website_endpoint
# }
# output "website_domain" {
#   value = aws_s3_bucket.bucket.website_domain
# }
