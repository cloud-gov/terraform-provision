

module "dev_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "development"
  domain              = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  app_subdomain       = "app.dev.us-gov-west-1.aws-us-gov.cloud.gov"
  admin_subdomain     = "dev.us-gov-west-1.aws-us-gov.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}