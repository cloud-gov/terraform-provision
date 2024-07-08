variable "remote_state_bucket" {
}

variable "remote_state_region" {
}

variable "staging_stack_name" {
}

terraform {
  required_providers {
    concourse = {
      source  = "terraform-provider-concourse/concourse"
      version = "~> 7.0"
    }
  }
}

provider "concourse" {
  url  = var.concourse_url
  team = "main"

  username = var.concourse_username
  password = var.concourse_password
}

resource "concourse_team" "main" {
  team_name = "main"

  owners = [
    "group:oauth:concourse.admin",
    "user:local:admin"
  ]

  viewers = [
    "group:oauth:concourse.viewer",
  ]
}

resource "concourse_team" "pages" {
  team_name = "pages"

  members = [
    "group:oauth:concourse.pages"
  ]
  viewers = [
    "group:oauth:concourse.viewer"
  ]

}

terraform {
  backend "s3" {
  }
}

data "terraform_remote_state" "staging" {
  backend   = "s3"
  workspace = "staging"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.staging_stack_name}/terraform.tfstate"
  }
}
