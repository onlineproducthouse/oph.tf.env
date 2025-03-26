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

    domain_name = local.host_output.endpoint
    origin_id   = var.www.cdn.certificate.domain_name
  }

  enabled             = true
  default_root_object = var.www.host.index_page

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    target_origin_id = var.www.cdn.certificate.domain_name
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

  aliases = [var.www.cdn.certificate.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.www.cdn.certificate.arn
    ssl_support_method  = "sni-only"
  }

  # web_acl_id = var.waf_web_acl_id
}

resource "aws_route53_record" "cdn_dns_record" {
  count = var.www.run == true ? 1 : 0

  name    = var.www.cdn.certificate.domain_name
  type    = "A"
  zone_id = var.www.cdn.hosted_zone_id

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

locals {
  cdn_output = {
    id             = aws_cloudfront_distribution.cdn.id
    domain_name    = aws_cloudfront_distribution.cdn.domain_name
    hosted_zone_id = aws_cloudfront_distribution.cdn.hosted_zone_id
  }
}
