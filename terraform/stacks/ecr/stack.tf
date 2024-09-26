terraform {
  backend "s3" {
  }
}

provider "aws" {
  use_fips_endpoint = true

  default_tags {
    tags = {
      deployment = "ecr"
    }
  }
}

data "terraform_remote_state" "tooling" {
  backend = "s3"
  config = {
    bucket = var.remote_state_bucket
    key    = "${var.tooling_stack_name}/terraform.tfstate"
  }
}


resource "aws_ecr_repository" "repository" {
  for_each = var.repositories

  name                 = each.key
  image_tag_mutability = "MUTABLE"
}

resource "aws_ecr_lifecycle_policy" "ecr_repository_lifecycle_policy" {
  for_each = var.repositories

  repository = each.key

  policy = <<EOF
  {
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images without tags",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 1
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Only keep the two latest images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 2
            },
            "action": {
                "type": "expire"
            }
        }
    ]
  }
  EOF
}
