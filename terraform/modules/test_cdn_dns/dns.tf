locals {
  test_cdn_subdomain                = trim(var.test_cdn_subdomain, ".")
  test_cdn_domain                   = trim(var.test_cdn_domain, ".")
  external_domain_broker_app_domain = "${local.test_cdn_subdomain}.${local.test_cdn_domain}.external-domains-${var.external_domain_broker_env}.cloud.gov"
}

resource "aws_route53_record" "test_cdn_acmechallenge" {
  zone_id = var.route53_zone_id
  name    = "_acme-challenge.${local.test_cdn_subdomain}"
  type    = "CNAME"

  ttl = 600
  records = [
    "_acme-challenge.${local.external_domain_broker_app_domain}"
  ]
}

resource "aws_route53_record" "test_cdn_cname" {
  zone_id = var.route53_zone_id
  name    = local.test_cdn_subdomain
  type    = "CNAME"

  ttl     = 600
  records = [local.external_domain_broker_app_domain]
}
