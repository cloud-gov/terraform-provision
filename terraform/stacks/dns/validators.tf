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
    "v=spf1 include:mail.zendesk.com include:cloud-gov-new.zendesk.com include:_spf.google.com ip4:${data.terraform_remote_state.tooling.outputs.nat_egress_ip_az1} ip4:${data.terraform_remote_state.tooling.outputs.nat_egress_ip_az2} ~all",
    "google-site-verification=jxczK0Pz1ybEFx79BlXIfeX2Cc5vs2YQuqvLnTYF9Bw",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk_support_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "support.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["cloud-gov-new.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_pages_zendesk_support_cname" {
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
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAjaTlZow4cEXZt/gUvZaVPrlsxzo4grF136MoAXLE5gz314FqsdXsHtCJzVHK+8zA4GajtZ8FLDUTqf+E+fJ9xaWUTfOxhtOccOOMKxTUuXcq+V3+mMad1MFOUxMSNfYtJmvWvpVlo+\"\"TGk70sZSRhhyUcMGqQobdPlAdv67iQsQZLj1I12EbPqByT+lZI57p8C1dVEYHxdzmPEFcaeIX97OPUNEOszDez5glQabg+UJPidgs/h+w+fTs8B2Jf6GN/Q/qLmjZSnGU3xbCqy4jWpNNvISu8jFmqXedwEG/xXv1Yk8oL361J5Oz/Y2mC/dlvbXLJWe8dBOLaKC0vesIMXQIDAQAB",
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
