#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "bucket_name" {
  type    = string
  default = "UnknownS3Bucket"
}

variable "owner" {
  type    = string
  default = ""
}

variable "environment_name" {
  type    = string
  default = ""
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name

  tags = {
    owner            = var.owner
    environment_name = var.environment_name
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
