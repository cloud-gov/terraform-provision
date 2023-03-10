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
      stack = "${var.stack_description}"
    }
  }
}

# We can't use FIPS for all S3 resources
# see https://github.com/hashicorp/terraform-provider-aws/issues/25717#issuecomment-1179797910
provider "aws" {
  alias = "standard"

  default_tags {
    tags = {
      deployment = "cloudfront-${var.stack_description}"
      stack = "${var.stack_description}"
    }
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

  providers = {
    aws.foo = aws.standard
    aws = aws.fips
  }
}

module "external_domain_broker_tests" {
  source = "../../modules/external_domain_broker_tests"

  aws_partition     = data.aws_partition.current.partition
  stack_description = var.stack_description

  providers = {
    aws = aws.fips
    aws.standard = aws.standard
  }
}

module "cdn_broker" {
  source = "../../modules/cdn_broker"

  account_id        = data.aws_caller_identity.current.account_id
  aws_partition     = data.aws_partition.current.partition
  username          = "cdn-broker-${var.stack_description}"
  bucket            = "cdn-broker-le-verify-${var.stack_description}"
  cloudfront_prefix = "cg-${var.stack_description}/*"
  hosted_zone       = var.cdn_broker_hosted_zone

  providers = {
    aws = aws.fips
    aws.standard = aws.standard
  }
}

module "limit_check_user" {
  source   = "../../modules/iam_user/limit_check_user"
  username = "limit-check-${var.stack_description}"

  providers = {
    aws = aws.fips
    aws.standard = aws.standard
  }
}

module "health_check_user" {
  source   = "../../modules/iam_user/health_check"
  username = "health-check-${var.stack_description}"

  providers = {
    aws = aws.fips
    aws.standard = aws.standard
  }
}

module "lets_encrypt_user" {
  source        = "../../modules/iam_user/lets_encrypt"
  aws_partition = data.aws_partition.current.partition
  hosted_zone   = var.lets_encrypt_hosted_zone
  username      = "lets-encrypt-${var.stack_description}"

  providers = {
    aws = aws.fips
    aws.standard = aws.standard
  }
}