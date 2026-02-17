output "s3_host_bucket_name" {
  value = aws_s3_bucket.host.id
}

output "cdn_id" {
  value = aws_cloudfront_distribution.cdn.id
}
