resource "aws_cloudwatch_log_group" "query_resolver_logs" {
  name = "${var.stack_description}-query-resolver-logs"
  # Keep for 5 years. This is the only option that is greater than the
  # minimum requirement of 30 months for M-21-31 Passive DNS data.
  retention_in_days = 1096

  tags = {
    Environment = var.stack_description
  }
}


resource "aws_route53_resolver_query_log_config" "resolver_config" {
  name            = "${var.stack_description}-query-resolver-logs"
  destination_arn = aws_cloudwatch_log_group.query_resolver_logs.arn

  tags = {
    Environment = var.stack_description
  }
}

resource "aws_route53_resolver_query_log_config_association" "resolver_config_association" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.resolver_config.id
  resource_id                  = var.vpc_id
}
