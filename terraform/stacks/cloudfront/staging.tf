module "staging_cloudfront" {
  source              = "../../modules/cloudfront/environment"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
  stack_description   = "staging"
}
