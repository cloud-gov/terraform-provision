provider "aws" {
  # this is for CI 
  # run deployments, provide jumpboxes, check on things, etc
  alias = "tooling"
}
provider "aws" {
  # this is for the tooling bosh 
  # deploy and monitor vms, scrape metrics, compliance agents, and smtp
  alias = "parentbosh"
  region = var.aws_default_region
  assume_role {
    role_arn = var.parent_assume_arn
  }
}
provider "aws" {
  region = var.aws_default_region
  assume_role {
    role_arn = var.assume_arn
  }
}


provider "aws" {
    alias = "commercial"
    region = var.aws_commercial_default_region
    access_key = var.aws_commercial_access_key
    secret_key = var.aws_commercial_secret_key
    assume_role {
      role_arn = var.commercial_assume_arn
    }
}

provider "aws" {
    alias = "toolingcommercial"
    region = var.aws_commercial_default_region
    access_key = var.aws_commercial_access_key
    secret_key = var.aws_commercial_secret_key
}