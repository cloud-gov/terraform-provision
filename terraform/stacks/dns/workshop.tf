#########################################
## Production                          ##
## pointers to gsa.gitlab-dedicated.us ##
#########################################
resource "aws_route53_record" "cloud_gov_workshop_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "workshop.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["gsa.gitlab-dedicated.us."]
}

resource "aws_route53_record" "cloud_gov_registry_workshop_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "registry.workshop.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["registry.gsa.gitlab-dedicated.us."]
}
