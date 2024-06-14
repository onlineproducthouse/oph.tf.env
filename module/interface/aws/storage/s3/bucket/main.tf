#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "bucket" {
  type = object({
    name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket.name
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
