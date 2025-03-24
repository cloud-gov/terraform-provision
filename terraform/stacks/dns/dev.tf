
resource "aws_route53_zone" "dev_zone" {
  name = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
}

resource "aws_route53_record" "dev_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.dev_zone.name_servers
}


module "dev_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "development"
  zone_id             = aws_route53_zone.dev_zone.zone_id
  domain              = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  app_subdomain       = "app.dev.us-gov-west-1.aws-us-gov.cloud.gov"
  admin_subdomain     = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}

resource "aws_route53_record" "cloud_gov_defectdojo_dev_cloud_gov_a" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "defectdojo.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_defectdojo_dev_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.dev_zone.zone_id
  name    = "defectdojo.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.outputs.main_lb_dns_name}"
    zone_id                = var.cloudfront_zone_id
    evaluate_target_health = false
  }
}
