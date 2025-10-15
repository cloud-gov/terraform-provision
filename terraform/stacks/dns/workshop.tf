#########################################
## Production                          ##
## delegation of workshop.cloud.gov to ##
## CloudFlare NSes managed by GitLab   ##
#########################################
resource "aws_route53_record" "cloud_gov_workshop_cloud_gov_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "workshop.cloud.gov."
  type    = "NS"
  ttl     = 10 # TODO - Bump to 1 hour once things are stable
  records = [
    "karl.ns.cloudflare.com.",
    "tina.ns.cloudflare.com.",
  ]
}
