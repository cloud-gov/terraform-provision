terraform {
  backend "s3" {
  }
}

data "aws_iam_account_alias" "current" {}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

  default_tags {
    tags = {
      account    = data.aws_iam_account_alias.current.account_alias
    }
  }
}