terraform {
  required_version = ">= 0.15"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 7.0.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "< 2.1"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "< 2.1"
    }
  }
}
