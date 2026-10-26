locals {
  platform_notifications_domain = "notifications.${var.admin_subdomain}"
}

resource "aws_route53_zone" "platform_notifications_mail_zone" {
  name    = local.platform_notifications_domain
  comment = "Domain used for sending alerts from platform"
}

resource "aws_route53_record" "platform_notifications_zone_ns" {
  zone_id = data.aws_route53_zone.apex_domain.zone_id
  name    = local.platform_notifications_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.platform_notifications_mail_zone.name_servers
}

resource "aws_route53_record" "platform_notifications_dkim_records" {
  for_each = toset(var.platform_notifications_ses_dkim_attribute_tokens)

  zone_id = aws_route53_zone.platform_notifications_mail_zone.zone_id
  name    = "${each.value}._domainkey.${local.platform_notifications_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_route53_record" "platform_notifications_dmarc" {
  zone_id = aws_route53_zone.platform_notifications_mail_zone.zone_id
  name    = "_dmarc.${local.platform_notifications_domain}"
  type    = "TXT"
  ttl     = "600"
  # p=reject is required by BOD-18-01: https://cyber.dhs.gov/assets/report/bod-18-01.pdf
  records = ["v=DMARC1; p=reject; rua=${local.dmarc_rua}; ruf=${local.dmarc_ruf}"]
}
