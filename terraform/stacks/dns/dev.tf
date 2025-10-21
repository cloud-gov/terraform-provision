
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
  source                         = "../../modules/environment_dns"
  stack_name                     = "development"
  zone_id                        = aws_route53_zone.dev_zone.zone_id
  domain                         = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  app_subdomain                  = "app.dev.us-gov-west-1.aws-us-gov.cloud.gov"
  admin_subdomain                = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  cf_lb_dns_name                 = data.terraform_remote_state.development.outputs.cf_lb_dns_name
  cf_apps_lb_dns_name            = data.terraform_remote_state.development.outputs.cf_apps_lb_dns_name
  cf_uaa_lb_dns_name             = data.terraform_remote_state.development.outputs.cf_uaa_lb_dns_name
  main_lb_dns_name               = data.terraform_remote_state.development.outputs.main_lb_dns_name
  diego_elb_dns_name             = data.terraform_remote_state.development.outputs.diego_elb_dns_name
  tcp_lb_dns_names               = data.terraform_remote_state.development.outputs.tcp_lb_dns_names
  log_alerts_ses_dkim_attributes = lookup(data.terraform_remote_state.development.outputs, "log_alerts_ses_dkim_attributes", [])
  log_alerts_dmarc_email         = var.log_alerts_dmarc_email
  log_alerts_ses_aws_region      = var.log_alerts_ses_aws_region
}
