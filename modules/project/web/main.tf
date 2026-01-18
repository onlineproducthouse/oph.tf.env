#region URL

resource "aws_acm_certificate" "acm" {
  region            = var.region
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(split("", dvo.domain_name), "*") != true
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = "60"
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "acm_cert_validation" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for item in aws_route53_record.acm : item.fqdn]
}

#endregion

#region Host

resource "aws_s3_bucket" "host" {
  bucket = aws_acm_certificate.acm.domain_name
}

resource "aws_s3_bucket_server_side_encryption_configuration" "host" {
  bucket = aws_s3_bucket.host.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "host" {
  bucket = aws_s3_bucket.host.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_ownership_controls" "host" {
  bucket = aws_s3_bucket.host.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "host" {
  bucket = aws_s3_bucket.host.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "host" {
  depends_on = [
    aws_s3_bucket_ownership_controls.host,
    aws_s3_bucket_public_access_block.host,
  ]

  bucket = aws_s3_bucket.host.id
  acl    = "public-read"
}

resource "aws_s3_bucket_website_configuration" "host" {
  bucket = aws_s3_bucket.host.id

  index_document {
    suffix = var.index_page
  }

  error_document {
    key = var.error_page
  }
}

resource "aws_s3_bucket_policy" "host" {
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

#endregion

#region CDN

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket_website_configuration.host.website_endpoint
    origin_id   = aws_acm_certificate.acm.domain_name
  }

  enabled             = true
  default_root_object = var.index_page

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    target_origin_id = aws_acm_certificate.acm.domain_name
    min_ttl          = 86400
    default_ttl      = 86400
    max_ttl          = 86400

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }
  }

  aliases = [aws_acm_certificate.acm.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.acm.arn
    ssl_support_method  = "sni-only"
  }

  # web_acl_id = var.waf_web_acl_id
}

resource "aws_route53_record" "domain_name" {
  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.acm.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = true
  }
}

#endregion
