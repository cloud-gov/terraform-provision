terraform {
  backend "s3" {
  }
}

provider "aws" {
  # cloudfront and route53 are regionless...
  endpoints {
    cloudfront = "https://cloudfront-fips.amazonaws.com"
    route53 = "https://route53-fips.amazonaws.com"
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
  hosted_zone   = var.lets_encrypt_hosted_zone
  username      = "lets-encrypt-${var.stack_description}"
}
