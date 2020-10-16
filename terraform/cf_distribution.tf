resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.webhost.bucket_regional_domain_name
    origin_id   = var.domain_name

  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
    prefix          = "url-shortener-logs"
  }

  aliases = [var.domain_name]

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = var.domain_name

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = "PriceClass_All"

  restrictions {
      geo_restriction {
          restriction_type = "none"
      }
  }

  tags = {
    Environment = "url-shortener"
  }

  viewer_certificate {
    acm_certificate_arn  = aws_acm_certificate.url_shortener.arn
    ssl_support_method = "sni-only"
  }

}

