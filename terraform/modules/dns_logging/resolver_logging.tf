module "dns_resolver_logs_bucket" {
  source          = "../s3_bucket/log_encrypted_bucket"
  bucket          = "${var.stack_description}-query-resolver-logs"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
  # need to exclude bucket policy otherwise we get access denied errors from rout53
  # query resolver logging configuration
  include_require_encrypted_put_bucket_policy = false
}

resource "aws_route53_resolver_query_log_config" "resolver_config" {
  name            = "${var.stack_description}-query-resolver-logs"
  destination_arn = module.dns_resolver_logs_bucket.bucket_arn

  tags = {
    Environment = var.stack_description
  }
}

resource "aws_route53_resolver_query_log_config_association" "resolver_config_association" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.resolver_config.id
  resource_id                  = var.vpc_id
}