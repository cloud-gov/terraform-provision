terraform {
  # 1.3.0: this stack uses
  # optional() in a variable type and variable validation blocks, neither of
  # which parses before 1.3.
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.58.0, < 7.0.0"
    }
  }
}
