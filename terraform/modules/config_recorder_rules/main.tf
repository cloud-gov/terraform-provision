module "config_results_bucket" {
  source = "../s3_bucket/log_encrypted_bucket"
  bucket          = "${var.stack_prefix}-config-results"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.stack_prefix}-config-recorder"
  role_arn = aws_iam_role.aws_config_role.arn
}

resource "aws_config_delivery_channel" "s3_delivery" {
  depends_on     = [aws_config_configuration_recorder.recorder]
  name           = "${var.stack_descstack_prefixription}-config-delivery"
  s3_bucket_name = module.config_results_bucket.bucket_name
}
