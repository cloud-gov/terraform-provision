resource "aws_route53_record" "cloud_gov_defectdojo_dev_cloud_gov_a" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "defectdojo.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_defectdojo_dev_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "defectdojo.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
