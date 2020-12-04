variable "aws_access_key" {}
variable "aws_secret_key" {}
variable "aws_region" {}

terraform {
  backend "s3" {}
}

provider "aws" {
  version    = "~> 2.40"
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}

variable "cloudfront_zone_id" {
  default = "Z33AYJ8TM3BH4J"
}

variable "remote_state_bucket" {}
variable "remote_state_region" {}

variable "tooling_stack_name" {}
variable "production_stack_name" {}
variable "staging_stack_name" {}
variable "development_stack_name" {}

data "terraform_remote_state" "tooling" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    region = "${var.remote_state_region}"
    key    = "${var.tooling_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "production" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    region = "${var.remote_state_region}"
    key    = "${var.production_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "staging" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    region = "${var.remote_state_region}"
    key    = "${var.staging_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "development" {
  backend = "s3"

  config {
    bucket = "${var.remote_state_bucket}"
    region = "${var.remote_state_region}"
    key    = "${var.development_stack_name}/terraform.tfstate"
  }
}

resource "aws_route53_zone" "cloud_gov_zone" {
  name = "cloud.gov."

  tags {
    Project = "dns"
  }
}

resource "aws_route53_record" "cloud_gov_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "cloud.gov."
  type    = "A"

  alias {
    name                   = "d2vy872d33xc5d.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "d2vy872d33xc5d.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_google_gsuite_mx" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
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
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "v=spf1 include:mail.zendesk.com include:_spf.google.com ~all",
    "google-site-verification=W6XRI1c1ebqaBV3vsGpkODQSirR5uN91uOG7Axrakzs",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk_support_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "support.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["cloud-gov.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_gsuite_dkim_txt" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "google._domainkey.cloud.gov"
  type    = "TXT"
  ttl     = 5

  records = [
    "v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAm6Zb6w+xgLv8afxiQYafPpsSPE9TMQWmTziXLxTEFXtLR+R08+7BjKG7pIpycaX10NGP66K9ZDdEYyGPEHLNU20Q/satC5QSO1hX3Aem38WOSdr5d6D/dJ6FUBooF1U/UFEO\"\"blCFyM6U6vAweaoNj753I05BB57Kra9DTFf96i26C0cMRguhpaehCsLL2MMgaOCidX0YUKMIpCaMLNyFRX0NjOn9ABiI4NLFg3uLs6i/B2RzT906mrWUZjwdbQCYqmJ0Z9OMSLYSn7ZmrZ8DHLMF8EaZvelR1zK/mCalEqNT0IMCgKrtrtSle7t31e+nsK+JnzlGgHKg3Z1GaB4FcQIDAQAB",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk_verification_txt" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendeskverification.cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "bb924f6a32697b2b",
  ]
}

resource "aws_route53_record" "cloud_gov_zendesk1_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk1.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail1.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk2_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk2.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail2.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk3_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk3.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail3.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk4_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk4.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["mail4.zendesk.com."]
}

resource "aws_route53_record" "cloud_gov_zendesk_domain_key1_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk1._domainkey.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["zendesk1._domainkey.zendesk.com"]
}

resource "aws_route53_record" "cloud_gov_zendesk_domain_key2_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "zendesk2._domainkey.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["zendesk2._domainkey.zendesk.com"]
}

resource "aws_route53_record" "cloud_gov_2a37e22b1f41ad3fe6af39f4fc38c1bc_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "2a37e22b1f41ad3fe6af39f4fc38c1bc.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["ac6c3680280b90d562df4de77465b14f900463b0.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_dc8dffe0fd99c8d067ce1bb5ef156f3e_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "dc8dffe0fd99c8d067ce1bb5ef156f3e.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["4c76d956c990d92cf796eff553d6926e22570fa2.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_domainkey_cloud_gov_txt" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "mail._domainkey.cloud.gov."
  type    = "TXT"
  ttl     = 300
  records = ["v=DKIM1; k=rsa; p=MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQCuZC9YRh2oodgnlo4L0r9O40n/uYWC1592cx/01l5DIA/gylo0MHlYJvgV/nsVDReC4IvhLFEfUceBXsFm8Cr3bK1Q+blnHp+DoDcRTcEE1Yunp6lwVqZZzBvEWL9aA/+duEGsy0CMfLH/x5GNztrVC7+jqUZFHd6yPDv9HfGyLwIDAQAB"]
}

resource "aws_route53_record" "cloud_gov_docs_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "docs.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["d2knjq618810db.cloudfront.net."]
}

resource "aws_route53_record" "cloud_gov_62c5ba6eb10ba1eec8fffd32f9a3cb7d_fr-stage_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "62c5ba6eb10ba1eec8fffd32f9a3cb7d.fr-stage.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["85b89d69fb926ddcd519063c645fff5dbd29a95f.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_star_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "prometheus.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "prometheus.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "alertmanager.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "alertmanager.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "grafana.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "grafana.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "doomsday.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "doomsday.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ssh_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ssh.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.diego_elb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_39e7c230acbbc55a537f450483f715f9_fr_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "39e7c230acbbc55a537f450483f715f9.fr.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["86c6cd8ef448865fc0ea0de3913d4e79ecccbdbc.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_star_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_app_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.app.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.cf_apps_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_app_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.app.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.cf_apps_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_admin_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "admin.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.admin_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_admin_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "admin.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.admin_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_admin_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "admin.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.admin_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_admin_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "admin.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.admin_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci-stage_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ci.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci-stage_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ci.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ci.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ci.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ci_dev2_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ci.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-Concourse-us-gov-west-1a-1305041237.us-gov-west-1.elb.amazonaws.com."
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "prometheus.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_prometheus_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "prometheus.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "alertmanager.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_alertmanager_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "alertmanager.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "grafana.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_grafana_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "grafana.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "doomsday.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_doomsday_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "doomsday.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

/* Platform logs */

resource "aws_route53_record" "cloud_gov_logs_platform_dev_env_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_dev_env_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_stage_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_stage_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_logs_platform_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "logs-platform.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_nessus_fr_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "nessus.fr.cloud.gov."
  type    = "CNAME"
  ttl     = 300

  records = [
    "dualstack.${data.terraform_remote_state.tooling.main_lb_dns_name}",
  ]
}

resource "aws_route53_record" "cloud_gov_ssh_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ssh.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.diego_elb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_uaa_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "opsuaa.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.opsuaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_uaa_dev2_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "opsuaa.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-bosh-uaa-2083417090.us-gov-west-1.elb.amazonaws.com."
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_login_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "opslogin.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.tooling.opsuaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ops_login_dev2_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "opslogin.dev2.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.tooling-bosh-uaa-2083417090.us-gov-west-1.elb.amazonaws.com."
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_dev_us_gov_west_1_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_dev_us_gov_west_1_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_fr-stage_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.fr-stage.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_fr-stage_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.fr-stage.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.staging.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_fr_cloud_gov_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.fr.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_idp_fr_cloud_gov_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "idp.fr.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.production.main_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_dev_env_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ssh_dev_env_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ssh.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.diego_elb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_ssh_dev_env_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "ssh.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.diego_elb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_star_dev_env_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "*.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_uaa_dev_env_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "uaa.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_uaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_uaa_dev_env_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "uaa.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_uaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_login_dev_env_a" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "login.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "A"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_uaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_uaa_login_env_aaaa" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "login.dev.us-gov-west-1.aws-us-gov.cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "dualstack.${data.terraform_remote_state.development.cf_uaa_lb_dns_name}"
    zone_id                = "${var.cloudfront_zone_id}"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_www_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "www.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["d2vy872d33xc5d.cloudfront.net."]
}

// The external_domain_broker is doing this differently, and creating the zone
// in terraform (gasp), and connecting it with an NS record inside the module .

resource "aws_route53_record" "cdn_broker_delegate" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "cdn-broker-test.cloud.gov."
  type    = "NS"
  ttl     = 300

  records = [
    "ns-1999.awsdns-57.co.uk.",
    "ns-1182.awsdns-19.org.",
    "ns-243.awsdns-30.com.",
    "ns-651.awsdns-17.net.",
  ]
}

resource "aws_route53_record" "star_app_cloud_gov_dv" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "_baa568061ce9f20600f5faa54e0032b2.app.cloud.gov."
  type    = "NS"
  ttl     = 300
  records = ["8025.dns-approval.sslmate.com."]
}

resource "aws_route53_record" "cloud_gov_b3b6346ca012f4c2600a876bec04df21_fr_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "b3b6346ca012f4c2600a876bec04df21.fr.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["f864c4904534089d70cf1b4d87d273d53605418d.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov_06c69b2987cb640e61fb65cc8213943d_fr-stage_cloud_gov_cname" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "06c69b2987cb640e61fb65cc8213943d.fr-stage.cloud.gov."
  type    = "CNAME"
  ttl     = 5
  records = ["a957810e491407b51f8ffebfe467ab376ca2335d.comodoca.com."]
}

resource "aws_route53_record" "cloud_gov__dmarc_cloud_gov_txt" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "_dmarc.cloud.gov."
  type    = "TXT"
  ttl     = 300

  records = [
    "v=DMARC1; p=reject; rua=mailto:dmarcreports@gsa.gov, mailto:reports@dmarc.cyber.dhs.gov, mailto:cloud-gov-operations@gsa.gov; ruf=mailto:dmarcfailures@gsa.gov; pct=100; fo=1",
  ]
}

resource "aws_route53_record" "dev2_delegate" {
  zone_id = "${aws_route53_zone.cloud_gov_zone.zone_id}"
  name    = "dev2.cloud.gov."
  type    = "NS"
  ttl     = 300

  records = [
    "ns-620.awsdns-13.net.",
    "ns-157.awsdns-19.com.",
    "ns-1126.awsdns-12.org.",
    "ns-1858.awsdns-40.co.uk.",
  ]
}

output "cloud_gov_ns" {
  value = "${aws_route53_zone.cloud_gov_zone.name_servers}"
}
