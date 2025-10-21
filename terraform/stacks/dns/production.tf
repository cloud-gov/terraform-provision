module "production_dns" {
  source                         = "../../modules/environment_dns"
  stack_name                     = "production"
  zone_id                        = aws_route53_zone.cloud_gov_zone.zone_id
  domain                         = "cloud.gov"
  app_subdomain                  = "app.cloud.gov"
  admin_subdomain                = "fr.cloud.gov"
  cf_lb_dns_name                 = data.terraform_remote_state.production.outputs.cf_lb_dns_name
  cf_apps_lb_dns_name            = data.terraform_remote_state.production.outputs.cf_apps_lb_dns_name
  cf_uaa_lb_dns_name             = data.terraform_remote_state.production.outputs.cf_uaa_lb_dns_name
  main_lb_dns_name               = data.terraform_remote_state.production.outputs.main_lb_dns_name
  diego_elb_dns_name             = data.terraform_remote_state.production.outputs.diego_elb_dns_name
  tcp_lb_dns_names               = data.terraform_remote_state.production.outputs.tcp_lb_dns_names
  log_alerts_ses_dkim_attributes = lookup(data.terraform_remote_state.production.outputs, "log_alerts_ses_dkim_attribute_tokens", [])
  log_alerts_dmarc_email         = var.log_alerts_dmarc_email
  log_alerts_ses_aws_region      = var.log_alerts_ses_aws_region
}

module "test_cdn_dns_production" {
  source                     = "../../modules/test_cdn_dns"
  route53_zone_id            = aws_route53_zone.cloud_gov_zone.zone_id
  test_cdn_domain            = "fr.cloud.gov"
  external_domain_broker_env = "production"
}
