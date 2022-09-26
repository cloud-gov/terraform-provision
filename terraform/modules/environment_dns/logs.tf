module "dns_resolver_logs_bucket" {
  source          = "../s3_bucket/log_encrypted_bucket"
  bucket          = "${var.stack_name}-query-resolver-logs"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
}

resource "aws_route53_resolver_query_log_config" "example" {
  name            = "${var.stack_name}-query-resolver-logs"
  destination_arn = module.dns_resolver_logs_bucket.bucket_arn

  tags = {
    Environment = var.stack_name
  }
}