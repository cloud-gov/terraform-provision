module "config_recorder" {
  source        = "../../../modules/config_recorder_rules"
  stack_prefix  = var.stack_prefix
  aws_partition = data.aws_partition.current
}
