resource "aws_cloudwatch_log_group" "audit_log" {
  name = "elasticsearch_broker_audit_log"
}
