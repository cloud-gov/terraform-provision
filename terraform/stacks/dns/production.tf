module "production_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "production"
  zone_id             = aws_route53_zone.cloud_gov_zone.zone_id
  domain              = "cloud.gov"
  app_subdomain       = "app.cloud.gov"
  admin_subdomain     = "fr.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}

module "test_cdn_dns_production" {
  source                     = "../../modules/test_cdn_dns"
  route53_zone_id            = aws_route53_zone.cloud_gov_zone.zone_id
  test_cdn_domain            = "fr.cloud.gov"
  external_domain_broker_env = "production"
}
