resource "aws_cloudwatch_event_rule" "rds_log_group_creation_broker" {
  for_each    = toset(var.environments)
  name        = "rds-log-group-creation-broker-${each.key}"
  description = "Triggers when a CloudWatch Log Group is created with an /aws/rds/instance/cg-aws-broker-<environment> prefix in the name."
  event_pattern = jsonencode({
    "source"      = ["aws.logs"],
    "detail-type" = ["AWS API Call via CloudTrail"],
    "detail" = {
      "eventSource" = ["logs.amazonaws.com"],
      "eventName"   = ["CreateLogGroup"],
      "requestParameters" = {
        "logGroupName" = [
          {
            prefix = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}"
          }
        ]
      }
    }
  })
}

resource "aws_cloudwatch_event_target" "rds_log_group_target" {
  for_each  = toset(var.environments)
  rule      = aws_cloudwatch_event_rule.rds_log_group_creation_broker[each.key].name
  role_arn  = aws_iam_role.eventbridge_lambda_role[each.key].arn
  arn       = resource.aws_lambda_function.cloudwatch_filter[each.key].arn
  target_id = resource.aws_lambda_function.cloudwatch_filter[each.key].id
}

locals {
  prefixes = {
    "production" : "prod",
    "staging" : "stage",
    "development" : "dev"
  }
}