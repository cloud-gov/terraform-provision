module "config_delegated_administrator" {
  source     = "../../../modules/config_delegated_administrator"
  account_id = var.config_delegated_administrator_account_id
}
