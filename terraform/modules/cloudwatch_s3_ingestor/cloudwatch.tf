resource "aws_cloudwatch_log_group" "test_log" {
for_each = toset(var.environments)
  name              = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}-smoketestenvironemnt"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

locals {
  prefixes = {
    "production" : "prod",
    "staging" : "stage",
    "development" : "dev"
  }
}

resource "aws_cloudwatch_log_subscription_filter" "test_subscription" {
  name            = "${local.prefixes[each.key]_test_subscription"
  log_group_name  = aws_cloudwatch_log_group.test_log.name
  filter_pattern  = "" 
  destination_arn = resource.aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].arn
}