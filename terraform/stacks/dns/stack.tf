variable "aws_access_key" {
}

variable "aws_secret_key" {
}

variable "aws_region" {
}

terraform {
  backend "s3" {
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region
}

variable "cloudfront_zone_id" {
  default = "Z33AYJ8TM3BH4J"
}

variable "remote_state_bucket" {
}

variable "remote_state_region" {
}

variable "tooling_stack_name" {
}

variable "production_stack_name" {
}

variable "staging_stack_name" {
}

variable "development_stack_name" {
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

resource "aws_route53_record" "cloud_gov_docs_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "docs.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["d2knjq618810db.cloudfront.net."]
}

/* Platform logs */

resource "aws_route53_record" "cloud_gov_www_cloud_gov_cname" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "www.cloud.gov."
  type    = "CNAME"
  ttl     = 60
  records = ["d2vy872d33xc5d.cloudfront.net."]
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


# delegate zones in root so modules can be called from
# child accounts later
resource "aws_route53_zone" "west_zone" {
  name = "west.cloud.gov"
}

resource "aws_route53_record" "west_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "west.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.west_zone.name_servers
}

module "tooling_west_dns" {
  source              = "../../modules/regionalmaster_dns"
  tooling_stack_name  = "master-west"
  zone_id             = aws_route53_zone.west_zone.zone_id
  subdomain           = "fr.west.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}


resource "aws_route53_zone" "westb_zone" {
  name = "wb.cloud.gov"
}

resource "aws_route53_record" "westb_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "wb.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.westb_zone.name_servers
}

module "westb_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "westb"
  zone_id             = aws_route53_zone.westb_zone.zone_id
  app_subdomain       = "app.wb.cloud.gov"
  admin_subdomain     = "fr.wb.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}

# delegate zones in root so modules can be called from
# child accounts later
resource "aws_route53_zone" "east_zone" {
  name = "east.cloud.gov"
}

resource "aws_route53_record" "east_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "east.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.east_zone.name_servers
}

module "tooling_east_dns" {
  source              = "../../modules/regionalmaster_dns"
  tooling_stack_name  = "master-east"
  cloudfront_zone_id  = "Z166TLBEWOO7G0"
  zone_id             = aws_route53_zone.east_zone.zone_id
  subdomain           = "fr.east.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}


resource "aws_route53_zone" "easta_zone" {
  name = "ea.cloud.gov"
}

resource "aws_route53_record" "easta_ns" {
  zone_id = aws_route53_zone.cloud_gov_zone.zone_id
  name    = "ea.cloud.gov"
  type    = "NS"
  ttl     = "30"
  records = aws_route53_zone.easta_zone.name_servers
}

module "easta_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "easta"
  cloudfront_zone_id  = "Z166TLBEWOO7G0"
  zone_id             = aws_route53_zone.easta_zone.zone_id
  app_subdomain       = "app.ea.cloud.gov"
  admin_subdomain     = "fr.ea.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}