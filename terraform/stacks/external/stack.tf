terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.8.0"
}

module "cdn_broker" {
  source = "../../modules/cdn_broker"

  account_id = "${var.account_id}"
  aws_partition = "${var.aws_partition}"
  username = "${var.cdn_broker_username}"
  bucket = "${var.cdn_broker_bucket}"
  cloudfront_prefix = "${var.cdn_broker_cloudfront_prefix}"
  hosted_zone = "${var.cdn_broker_hosted_zone}"
}

module "limit_check_user" {
  source = "../../modules/iam_user/limit_check_user"
  username = "limit-check-${var.stack_description}"
}
