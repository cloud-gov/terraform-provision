data "terraform_remote_state" "ecr" {
  backend = "s3"

  config = {
    bucket = var.ecr_remote_state_bucket
    region = var.ecr_remote_state_region
    key    = "${var.ecr_stack_name}/terraform.tfstate"
  }
}

locals {
  csb_ecr_repository_arn        = data.terraform_remote_state.ecr.outputs.repository_arns["cg-csb"]
  csb_helper_ecr_repository_arn = data.terraform_remote_state.ecr.outputs.repository_arns["csb-helper"]
}

// A user with ECR pull permissions so Cloud Foundry can pull the CSB image.
module "ecr_user" {
  source          = "../../../iam_user/ecr_pull_user"
  username        = "${var.stack_description}-csb-ecr"
  repository_arns = [local.csb_ecr_repository_arn, local.csb_helper_ecr_repository_arn]
}
