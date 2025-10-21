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
  source                         = "../../modules/environment_dns"
  stack_name                     = "staging"
  zone_id                        = aws_route53_zone.staging_zone.zone_id
  domain                         = "fr-stage.cloud.gov"
  app_subdomain                  = "app.fr-stage.cloud.gov"
  admin_subdomain                = "fr-stage.cloud.gov"
  cf_lb_dns_name                 = data.terraform_remote_state.staging.outputs.cf_lb_dns_name
  cf_apps_lb_dns_name            = data.terraform_remote_state.staging.outputs.cf_apps_lb_dns_name
  cf_uaa_lb_dns_name             = data.terraform_remote_state.staging.outputs.cf_uaa_lb_dns_name
  main_lb_dns_name               = data.terraform_remote_state.staging.outputs.main_lb_dns_name
  diego_elb_dns_name             = data.terraform_remote_state.staging.outputs.diego_elb_dns_name
  tcp_lb_dns_names               = data.terraform_remote_state.staging.outputs.tcp_lb_dns_names
  log_alerts_ses_dkim_attributes = lookup(data.terraform_remote_state.staging.outputs, "log_alerts_ses_dkim_attribute_tokens", [])
  log_alerts_dmarc_email         = var.log_alerts_dmarc_email
  log_alerts_ses_aws_region      = var.log_alerts_ses_aws_region
}

module "test_cdn_dns_staging" {
  source                     = "../../modules/test_cdn_dns"
  route53_zone_id            = aws_route53_zone.staging_zone.zone_id
  test_cdn_domain            = "fr-stage.cloud.gov"
  external_domain_broker_env = "staging"
}
