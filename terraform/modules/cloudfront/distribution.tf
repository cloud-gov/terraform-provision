# Terraform module for a single CloudFront distribution with Shield Advanced enabled.

locals {
  originID = "${var.origin.lb_dns_name}-origin"
}

resource "aws_cloudfront_distribution" "distribution" {
  origin {
    origin_id   = local.originID
    domain_name = var.origin.lb_dns_name
    custom_origin_config {
      http_port              = var.origin.lb_http_port
      https_port             = var.origin.lb_https_port
      origin_protocol_policy = "https-only"
      origin_ssl_protocols   = ["TLSv1.3"]
    }
  }

  enabled         = true
  is_ipv6_enabled = true

  aliases = var.aliases

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  default_cache_behavior {
    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]
    forwarded_values {
      cookies {
        forward = "all"
      }
      query_string = true
    }
    target_origin_id       = local.originID
    viewer_protocol_policy = "redirect-to-https"
  }
  viewer_certificate {
    # Use the default until we cut over DNS to point to the distribution.
    cloudfront_default_certificate = true
  }
  web_acl_id = var.acl_arn
}

resource "aws_shield_protection" "shield_protection" {
  name         = aws_cloudfront_distribution.distribution.domain_name
  resource_arn = aws_cloudfront_distribution.distribution.arn
}
