resource "aws_route53_record" "cloud_gov_google_gsuite_mx" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "cloud.gov."
  type    = "MX"
  ttl     = 100

  records = [
    "1         ASPMX.L.GOOGLE.COM.",
    "5    ALT1.ASPMX.L.GOOGLE.COM.",
    "5    ALT2.ASPMX.L.GOOGLE.COM.",
    "10   ALT3.ASPMX.L.GOOGLE.COM.",
    "10   ALT4.ASPMX.L.GOOGLE.COM.",
  ]
}

resource "aws_route53_record" "cloud_gov_cloud_gov_txt" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:mail.zendesk.com include:_spf.google.com ~all",
    "google-site-verification=W6XRI1c1ebqaBV3vsGpkODQSirR5uN91uOG7Axrakzs",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk_support_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "support.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["cloud-gov-new.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk_support_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "pages-support.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["cloud-gov-pages.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_gsuite_dkim_txt" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "google._domainkey.cloud.gov"
  type    = "TXT"
  ttl     = 5

  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6Zb6w+xgLv8afxiQYafPpsSPE9TMQWmTziXLxTEFXtLR+R08+7BjKG7pIpycaX10NGP66K9ZDdEYyGPEHLNU20Q/satC5QSO1hX3Aem38WOSdr5d6D/dJ6FUBooF1U/UFEO\"\"blCFyM6U6vAweaoNj753I05BB57Kra9DTFf96i26C0cMRguhpaehCsLL2MMgaOCidX0YUKMIpCaMLNyFRX0NjOn9ABiI4NLFg3uLs6i/B2RzT906mrWUZjwdbQCYqmJ0Z9OMSLYSn7ZmrZ8DHLMF8EaZvelR1zK/mCalEqNT0IMCgKrtrtSle7t31e+nsK+JnzlGgHKg3Z1GaB4FcQIDAQAB",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk_verification_txt" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendeskverification.cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "bb924f6a32697b2b",
    "57a42f5dc9fd8c6a",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk1_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk1.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail1.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk2_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk2.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail2.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk3_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk3.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail3.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk4_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk4.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail4.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk_domain_key1_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk1._domainkey.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["zendesk1._domainkey.zendesk.com"]
}

resource "aws_route53_record" "cloud_gov_zendesk_domain_key2_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "zendesk2._domainkey.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["zendesk2._domainkey.zendesk.com"]
}

resource "aws_route53_record" "cloud_gov_2a37e22b1f41ad3fe6af39f4fc38c1bc_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "2a37e22b1f41ad3fe6af39f4fc38c1bc.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["ac6c3680280b90d562df4de77465b14f900463b0.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_dc8dffe0fd99c8d067ce1bb5ef156f3e_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "dc8dffe0fd99c8d067ce1bb5ef156f3e.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["4c76d956c990d92cf796eff553d6926e22570fa2.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_domainkey_cloud_gov_txt" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "mail._domainkey.cloud.gov."
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCuZC9YRh2oodgnlo4L0r9O40n/uYWC1592cx/01l5DIA/gylo0MHlYJvgV/nsVDReC4IvhLFEfUceBXsFm8Cr3bK1Q+blnHp+DoDcRTcEE1Yunp6lwVqZZzBvEWL9aA/+duEGsy0CMfLH/x5GNztrVC7+jqUZFHd6yPDv9HfGyLwIDAQAB"]
}

resource "aws_route53_record" "cloud_gov__dmarc_cloud_gov_txt" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_dmarc.cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=reject; rua=mailto:dmarcreports@gsa.gov, mailto:reports@dmarc.cyber.dhs.gov, mailto:cloud-gov-operations@gsa.gov; ruf=mailto:dmarcfailures@gsa.gov; pct=100; fo=1",
  ]
}
