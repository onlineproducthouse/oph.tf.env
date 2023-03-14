#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cdn" {
  type = object({
    hosted_zone_id = string
    certificate = object({
      arn         = string
      domain_name = string
    })
  })

  default = {
    hosted_zone_id = ""
    certificate = {
      arn         = ""
      domain_name = ""
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_cloudfront_distribution" "cdn" {
  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = aws_s3_bucket_website_configuration.host_web_config.website_endpoint
    origin_id   = var.cdn.certificate.domain_name
  }

  enabled             = true
  default_root_object = var.host.index_page

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    target_origin_id = var.cdn.certificate.domain_name
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

  aliases = [var.cdn.certificate.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.cdn.certificate.arn
    ssl_support_method  = "sni-only"
  }

  # web_acl_id = var.waf_web_acl_id

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_route53_record" "cdn_dns_record" {
  name    = var.cdn.certificate.domain_name
  type    = "A"
  zone_id = var.cdn.hosted_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "cdn" {
  value = {
    id             = aws_cloudfront_distribution.cdn.id
    domain_name    = aws_cloudfront_distribution.cdn.domain_name
    hosted_zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
  }
}
