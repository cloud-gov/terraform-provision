resource "aws_cloudwatch_log_group" "test_log" {
for_each = toset(var.environments)
  name              = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}-smoketestenvironemnt"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_cloudwatch_log_subscription_filter" "test_subscription" {
  for_each = toset(var.environments)
  name = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}-smoketestenvironment"
  log_group_name  = aws_cloudwatch_log_group.test_log[each.key].name
  filter_pattern  = "" 
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].arn
  role_arn        = resource.aws_iam_role.cloudwatch_role[each.key].arn
}