
# Create the terraform-provision user, output is fed to cg-provision.yml in aws_access_key_id and aws_secret_access_key
module "terraform_provision_user" {
  source   = "../../modules/iam_user/terraform_provision"
}

provider "aws" {
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "cg-provision"
      provisioner = "terraform"
    }
  }
}

terraform {
  backend "s3" {
  }
}