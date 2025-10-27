resource "aws_cloudwatch_event_rule" "rds_log_group_creation_broker" {
  for_each       = toset(var.environments)
  name        = "rds-log-group-creation-broker"
  description = "Triggers when a CloudWatch Log Group is created with an /aws/rds/instance/cg-aws-broker-dev prefix in the name."
  role = aws_iam_role.eventbridge_lambda_role[each.key].arn
  event_pattern = jsonencode({
    "source"      = ["aws.logs"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    "detail" = {
      "eventSource" = ["logs.amazonaws.com"],
      "eventName"   = ["CreateLogGroup"],
      "requestParameters" = {
        "logGroupName" = [
          {
            prefix = "/aws/rds/instance/cg-aws-broker-${each.key == "production" ? "prd" : (each.key == "staging" ? "stg" : "dev")}"
          }
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "rds_log_group_target" {
  for_each       = toset(var.environments)
  rule      = aws_cloudwatch_event_rule.rds_log_group_creation_broker[each.key].name
  arn       = resource.aws_lambda_function.cloudwatch_filter[each.key].arn
  target_id = resource.aws_lambda_function.cloudwatch_filter[each.key].id
}