terraform {
  backend "s3" {}
}

provider "aws" {
  version = "~> 1.12.0"
}

data "terraform_remote_state" "target_vpc" {
  backend = "s3"
  config {
    bucket = "${var.remote_state_bucket}"
    key = "${var.target_stack_name}/terraform.tfstate"
  }
}

module "vpc" {
  source = "../../modules/bosh_vpc"
}

module "vpc_peering" {
  source = "../../modules/vpc_peering"
}
