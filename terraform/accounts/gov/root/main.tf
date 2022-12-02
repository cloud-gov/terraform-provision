module "config_delegated_administrator" {
  source     = "../../../modules/config_delegated_administrator"
  account_id = var.config_delegated_administrator_account_id
}

module "config_recorder" {
  source        = "../../../modules/config_recorder_rules"
  stack_prefix  = var.stack_prefix
  aws_partition = data.aws_partition.current
}
