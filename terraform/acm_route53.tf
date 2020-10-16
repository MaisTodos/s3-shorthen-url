data "aws_route53_zone" "url_shortener" {
  name         = var.domain_name
}

resource "aws_acm_certificate" "url_shortener" {
  domain_name       = var.domain_name
  validation_method = "DNS"
}

resource "aws_route53_record" "acm_validation" {
  for_each = {
    for dvo in aws_acm_certificate.url_shortener.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = data.aws_route53_zone.url_shortener.zone_id
}

resource "aws_route53_record" "url_shortener" {
  zone_id         = data.aws_route53_zone.url_shortener.zone_id
  name            = var.domain_name
  type            = "A"

  alias {
    name                    = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                 = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health  = false
  }
}

resource "aws_acm_certificate_validation" "acm_validation" {
  certificate_arn         = aws_acm_certificate.url_shortener.arn
  validation_record_fqdns = [for record in aws_route53_record.acm_validation : record.fqdn]
}