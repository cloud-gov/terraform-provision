resource "aws_cloudwatch_log_group" "audit_log" {
  name = "${var.stack_description}-elasticsearch_broker_audit_log"
  # Lowest allowed value that fulfills M-21-31 reqs of storing for 30 months
  retention_in_days = 1827
}
