resource "aws_organizations_delegated_administrator" "config_delegated_administrator" {
  account_id        = var.config_delegated_administrator_account_id
  service_principal = "config.amazonaws.com"
}