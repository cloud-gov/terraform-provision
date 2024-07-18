# Most stacks do not pass credentials this way. For an explanation of why
# access and state are managed differently in the DNS stack compared to the
# other stacks, see README.md, "DNS Stack" in the root of the repo.


terraform {
  backend "s3" {
  }
}

provider "aws" {
  access_key        = var.aws_access_key
  secret_key        = var.aws_secret_key
  region            = var.aws_region
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "dns-westa-hub"
    }
  }
}
