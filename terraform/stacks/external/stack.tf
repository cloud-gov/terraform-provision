terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.39.0"
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

module "cdn_broker" {
  source = "../../modules/cdn_broker"

  account_id = "${data.aws_caller_identity.current.account_id}"
  aws_partition = "${data.aws_partition.current.partition}"
  username = "${var.cdn_broker_username}"
  bucket = "${var.cdn_broker_bucket}"
  cloudfront_prefix = "${var.cdn_broker_cloudfront_prefix}"
  hosted_zone = "${var.cdn_broker_hosted_zone}"
}

module "limit_check_user" {
  source = "../../modules/iam_user/limit_check_user"
  username = "limit-check-${var.stack_description}"
}

module "lets_encrypt_user" {
  source = "../../modules/iam_user/lets_encrypt"
  aws_partition = "${data.aws_partition.current.partition}"
  hosted_zone = "${var.lets_encrypt_hosted_zone}"
  username = "lets-encrypt-${var.stack_description}"
}

module "domain_broker_v2_user" {
  source = "../../modules/iam_user/lets_encrypt"
  aws_partition = "${data.aws_partition.current.partition}"
  hosted_zone = "${var.lets_encrypt_hosted_zone}"
  username = "domain-broker-v2-${var.stack_description}"
}