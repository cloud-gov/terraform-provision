resource "aws_cloudwatch_log_group" "external_domain_waf_logs" {
  name              = "aws-waf-logs-external-domain-broker-${var.stack_description}"
  retention_in_days = 365
}
