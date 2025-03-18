terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias = "fips"

  use_fips_endpoint = true
  default_tags {
    tags = {
      deployment = "external-${var.stack_description}"
      stack      = "${var.stack_description}"
    }
  }
}

# We can't use FIPS for all S3 resources
# see https://github.com/hashicorp/terraform-provider-aws/issues/25717#issuecomment-1179797910
provider "aws" {
  alias = "standard"

  default_tags {
    tags = {
      deployment = "external-${var.stack_description}"
      stack      = "${var.stack_description}"
    }
  }
}

data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

module "external_domain_broker" {
  source = "../../modules/external_domain_broker"

  account_id        = data.aws_caller_identity.current.account_id
  stack_description = var.stack_description
  aws_partition     = data.aws_partition.current.partition
  aws_region        = data.aws_region.current.name

  waf_rate_limit_challenge_threshold = var.external_domain_waf_rate_limit_challenge_threshold
  waf_rate_limit_count_threshold     = var.external_domain_waf_rate_limit_count_threshold

  providers = {
    aws          = aws.fips
    aws.standard = aws.standard
  }
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
  count    = var.stack_description == "production" ? 1 : 0
  source   = "../../modules/iam_user/limit_check_user"
  username = "limit-check-${var.stack_description}"
}

module "health_check_user" {
  source   = "../../modules/iam_user/health_check"
  username = "health-check-${var.health_check_env}"
}

module "lets_encrypt_user" {
  source        = "../../modules/iam_user/lets_encrypt"
  aws_partition = data.aws_partition.current.partition
  hosted_zone   = var.lets_encrypt_hosted_zone
  username      = "lets-encrypt-${var.stack_description}"
}

module "csb_iam" {
  source = "../../modules/csb/iam/commercial"

  stack_description = var.stack_description
}

module "sns" {
  source = "../../modules/sns"

  sns_cg_platform_notifications_name        = "${var.stack_description}-platform-notifications"
  sns_cg_platform_notifications_email       = var.sns_cg_platform_notifications_email
  sns_cg_platform_slack_notifications_name  = "${var.stack_description}-platform-slack-notifications"
  sns_cg_platform_slack_notifications_email = var.sns_cg_platform_slack_notifications_email
}

module "terraform_state_reader" {
  source = "../../modules/iam_user/s3_bucket_readonly"

  bucket_name = var.terraform_state_bucket
  username    = "${var.stack_description}-terraform-state-reader"
}
