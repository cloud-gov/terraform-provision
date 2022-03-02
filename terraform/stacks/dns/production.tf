module "production_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "production"
  domain              = "cloud.gov"
  app_subdomain       = "app.cloud.gov"
  admin_subdomain     = "fr.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}