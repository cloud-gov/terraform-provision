locals {
  log_alerts_mail_subdomain = "log-alerts.${var.domain}"
}

resource "aws_route53_zone" "log_alerts_mail_zone" {
  name    = local.log_alerts_mail_subdomain
  comment = "Domain used for sending alerts from logs system"
}

resource "aws_route53_record" "brokered_log_alerts_zone_ns" {
  zone_id = data.aws_route53_zone.apex_domain.zone_id
  name    = local.log_alerts_mail_subdomain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.log_alerts_mail_zone.name_servers
}
