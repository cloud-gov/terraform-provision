
data "terraform_remote_state" "tooling" {
  backend = "s3"

  config = {
    bucket = var.remote_state_bucket
    region = var.remote_state_region
    key    = "${var.tooling_stack_name}/terraform.tfstate"
  }
}
