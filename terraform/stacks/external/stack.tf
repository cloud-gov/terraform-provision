terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias = "apex"
}
provider "aws" {
  region = var.commercial_aws_default_region
  assume_role {
    role_arn = var.commercial_assume_arn
  }
}

data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}

module "external_domain_broker" {
  source = "../../modules/external_domain_broker"

  account_id        = data.aws_caller_identity.current.account_id
  stack_description = var.stack_description
  aws_partition     = data.aws_partition.current.partition
}

module "external_domain_broker_tests" {
  source = "../../modules/external_domain_broker_tests"

  aws_partition     = data.aws_partition.current.partition
  stack_description = var.stack_description
}

module "cdn_broker" {
  source = "../../modules/cdn_broker"

  account_id        = data.aws_caller_identity.current.account_id
  aws_partition     = data.aws_partition.current.partition
  username          = "cdn-broker-${var.stack_description}"
  bucket            = "cdn-broker-le-verify-${var.stack_description}"
  cloudfront_prefix = "cg-${var.stack_description}/*"
  hosted_zone       = var.cdn_broker_hosted_zone
}

module "limit_check_user" {
  source   = "../../modules/iam_user/limit_check_user"
  username = "limit-check-${var.stack_description}"
}

module "health_check_user" {
  source   = "../../modules/iam_user/health_check"
  username = "health-check-${var.stack_description}"
}

module "lets_encrypt_user" {
  source        = "../../modules/iam_user/lets_encrypt"
  aws_partition = data.aws_partition.current.partition
  hosted_zone   = var.domain
  username      = "lets-encrypt-${var.stack_description}"
}

module "dns_zone" {
  source = "../../modules/dns_zone"
  count  = var.domain == "cloud.gov" ? 0 : 1
  providers = {
    aws      = aws
    aws.apex = aws.apex
  }
  domain = var.domain
  parent_zone_id = var.cloud_gov_zone_zone_id
}