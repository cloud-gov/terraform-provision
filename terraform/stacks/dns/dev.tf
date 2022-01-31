
resource "aws_route53_zone" "dev_zone" {
    name = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
}

# this is the switch we flip to make it active - before we turn this on, 
# the new zone does nothing
#resource "aws_route53_record" "dev_ns" {
#  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
#  name    = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
#  type    = "NS"
#  ttl     = "30"
#  records = aws_route53_zone.dev_zone.name_servers
#}


module "dev_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "dev"
  zone_id             = aws_route53_zone.dev_zone.zone_id
  app_subdomain       = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  admin_subdomain     = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}