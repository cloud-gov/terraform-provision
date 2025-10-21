locals {
  log_alerts_domain = "log-alerts.${var.domain}"

  # rua=mailto:reports@dmarc.cyber.dhs.gov is required by BOD-18-01: https://cyber.dhs.gov/assets/report/bod-18-01.pdf
  dmarc_rua = join(
    ",",
    [
      "mailto:reports@dmarc.cyber.dhs.gov",
      "mailto:${var.log_alerts_dmarc_email}"
    ]
  )
  dmarc_ruf = "mailto:${var.log_alerts_dmarc_email}"
}

resource "aws_route53_zone" "log_alerts_mail_zone" {
  name    = local.log_alerts_domain
  comment = "Domain used for sending alerts from logs system"
}

resource "aws_route53_record" "brokered_log_alerts_zone_ns" {
  zone_id = data.aws_route53_zone.apex_domain.zone_id
  name    = local.log_alerts_domain
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.log_alerts_mail_zone.name_servers
}

resource "aws_route53_record" "log_alerts_dkim_records" {
  for_each = toset(var.log_alerts_ses_dkim_attribute_tokens)

  zone_id = aws_route53_zone.log_alerts_mail_zone.zone_id
  name    = "${each.value}._domainkey.${local.log_alerts_domain}"
  type    = "CNAME"
  ttl     = "600"
  records = ["${each.value}.dkim.amazonses.com"]
}

resource "aws_route53_record" "log_alerts_dmarc" {
  zone_id = aws_route53_zone.log_alerts_mail_zone.zone_id
  name    = "_dmarc.${local.log_alerts_domain}"
  type    = "TXT"
  ttl     = "600"
  # p=reject is required by BOD-18-01: https://cyber.dhs.gov/assets/report/bod-18-01.pdf
  records = ["v=DMARC1; p=reject; rua=${local.dmarc_rua}; ruf=${local.dmarc_ruf}"]
}

resource "aws_route53_record" "log_alerts_mx" {
  zone_id = aws_route53_zone.log_alerts_mail_zone.zone_id
  name    = local.log_alerts_domain
  type    = "MX"
  ttl     = "600"
  records = ["10 feedback-smtp.${var.log_alerts_ses_aws_region}.amazonses.com"]
}

resource "aws_route53_record" "log_alerts_spf" {
  zone_id = aws_route53_zone.log_alerts_mail_zone.zone_id
  name    = local.log_alerts_domain
  type    = "TXT"
  ttl     = "600"
  records = ["v=spf1 include:amazonses.com -all"]
}
