terraform {
  backend "s3" {
  }
}

provider "aws" {
}

provider "aws" {
  region = var.aws_default_region

  endpoints {
    s3 = "https://s3-fips.${var.aws_default_region}.amazonaws.com"
  }
}

data "aws_partition" "current" {
}