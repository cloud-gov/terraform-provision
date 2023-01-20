resource "aws_cloudwatch_log_group" "audit_log" {
  name = "${var.stack_description}-elasticsearch_broker_audit_log"
}
