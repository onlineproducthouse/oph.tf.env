#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_cloudfront_distribution" "cdn" {
  count = var.web.run == true ? 1 : 0

  origin {
    custom_origin_config {
      http_port              = "80"
      https_port             = "443"
      origin_protocol_policy = "http-only"
      origin_ssl_protocols   = ["TLSv1", "TLSv1.1", "TLSv1.2"]
    }

    domain_name = local.host_output.endpoint
    origin_id   = var.web.cdn.certificate.domain_name
  }

  enabled             = true
  default_root_object = var.web.host.index_page

  default_cache_behavior {
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    target_origin_id = var.web.cdn.certificate.domain_name
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

  aliases = [var.web.cdn.certificate.domain_name]

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = var.web.cdn.certificate.arn
    ssl_support_method  = "sni-only"
  }

  # web_acl_id = var.waf_web_acl_id
}

resource "aws_route53_record" "cdn_dns_record" {
  count = var.web.run == true ? 1 : 0

  name    = var.web.cdn.certificate.domain_name
  type    = "A"
  zone_id = var.web.cdn.hosted_zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_cloudfront_distribution.cdn[0].domain_name
    zone_id                = aws_cloudfront_distribution.cdn[0].hosted_zone_id
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  null_cdn_output = {
    id             = ""
    domain_name    = ""
    hosted_zone_id = ""
  }
}

locals {
  cdn_output = var.web.run == true ? {
    id             = aws_cloudfront_distribution.cdn[0].id
    domain_name    = aws_cloudfront_distribution.cdn[0].domain_name
    hosted_zone_id = aws_cloudfront_distribution.cdn[0].hosted_zone_id
  } : local.null_cdn_output
}
