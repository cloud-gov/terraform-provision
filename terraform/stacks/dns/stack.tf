terraform {
  backend "s3" {
  }
}

provider "aws" {
  access_key        = var.aws_access_key
  secret_key        = var.aws_secret_key
  region            = var.aws_region
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "dns"
    }
  }
}

data "terraform_remote_state" "tooling" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.tooling_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "production" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.production_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "staging" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.staging_stack_name}/terraform.tfstate"
  }
}

data "terraform_remote_state" "development" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.development_stack_name}/terraform.tfstate"
  }
}

resource "aws_route53_zone" "cloud_gov_zone" {
  name = "cloud.gov."

  tags = {
    Project = "dns"
  }
}

resource "aws_route53_record" "cloud_gov_cloud_gov_a" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "cloud.gov."
  type    = "A"

  alias {
    name                   = "d2vy872d33xc5d.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_cloud_gov_aaaa" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "cloud.gov."
  type    = "AAAA"

  alias {
    name                   = "d2vy872d33xc5d.cloudfront.net."
    zone_id                = "Z2FDTNDATAQYW2"
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "cloud_gov_cloud_gov_acme_challenge" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_acme-challenge.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["_acme-challenge.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov_www_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "www.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["www.cloud.gov.external-domains-production.cloud.gov."]
}

resource "aws_route53_record" "cloud_gov_www_cloud_gov_acme_challenge" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "_acme-challenge.www.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["_acme-challenge.www.cloud.gov.external-domains-production.cloud.gov."]
}

// The external_domain_broker is doing this differently, and creating the zone
// in terraform (gasp), and connecting it with an NS record inside the module .

resource "aws_route53_record" "cdn_broker_delegate" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
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
