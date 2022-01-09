# I think the dev2 test is dead at this point, and all of this can be nuked


resource "aws_route53_record" "cloud_gov_ci_dev2_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ci.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-Concourse-us-gov-west-1a-1305041237.us-gov-west-1.elb.amazonaws.com."
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}


resource "aws_route53_record" "cloud_gov_ops_uaa_dev2_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "opsuaa.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-bosh-uaa-2083417090.us-gov-west-1.elb.amazonaws.com."
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_login_dev2_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "opslogin.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-bosh-uaa-2083417090.us-gov-west-1.elb.amazonaws.com."
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "dev2_delegate" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "dev2.cloud.gov."
  type    = "NS"
  ttl     = 300

  records = [
    "ns-620.awsdns-13.net.",
    "ns-157.awsdns-19.com.",
    "ns-1126.awsdns-12.org.",
    "ns-1858.awsdns-40.co.uk.",
  ]
}
