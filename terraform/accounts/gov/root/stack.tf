terraform {
  backend "s3" {
  }
}

provider "aws" {
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  region     = var.aws_region

  endpoints {
    s3 = "https://s3-fips.${var.aws_default_region}.amazonaws.com"
  }
}

data "aws_partition" "current" {
}