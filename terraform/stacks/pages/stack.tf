terraform {
  backend "s3" {
  }
}

provider "aws" {
  alias = "fips"

  use_fips_endpoint = true
  default_tags {
    tags = {
      deployment = "${var.stack_description}"
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
      deployment = "${var.stack_description}"
      stack      = "${var.stack_description}"
    }
  }
}

data "aws_partition" "current" {
}

data "aws_caller_identity" "current" {
}

data "aws_region" "current" {}

module "pages_buckets_manager" {
  source = "../../modules/iam_user/pages_buckets_manager"

  bucket_prefix = var.pages_bucket_prefix
  username    = "${var.stack_description}-terraform-state-reader"
}
