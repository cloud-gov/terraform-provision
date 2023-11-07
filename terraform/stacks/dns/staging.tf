resource "aws_route53_zone" "staging_zone" {
  name = "fr-stage.cloud.gov"
}

resource "aws_route53_record" "staging_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "fr-stage.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.staging_zone.name_servers
}


module "staging_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "staging"
  zone_id             = aws_route53_zone.staging_zone.zone_id
  domain              = "fr-stage.cloud.gov"
  app_subdomain       = "app.fr-stage.cloud.gov"
  admin_subdomain     = "fr-stage.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}

module "test_cdn_dns" {
  source                     = "../../modules/test_cdn_dns"
  route53_zone_id            = aws_route53_zone.staging_zone.zone_id
  test_cdn_domain            = "fr-stage.cloud.gov"
  external_domain_broker_env = "staging"
}
