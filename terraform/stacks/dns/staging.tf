module "staging_dns" {
  source              = "../../modules/environment_dns"
  stack_name          = "staging"
  domain              = "fr-stage.cloud.gov"
  app_subdomain       = "app.fr-stage.cloud.gov"
  admin_subdomain     = "fr-stage.cloud.gov"
  remote_state_bucket = var.remote_state_bucket
  remote_state_region = var.remote_state_region
}