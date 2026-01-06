resource "aws_cloudwatch_log_group" "test_log" {
  for_each          = toset(var.environments)
  name              = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}-smoketestenvironemnt"
  retention_in_days = 7

  tags = merge(local.common_tags, {
    Environment             = each.key
    "Service offering name" = "aws-rds"
    "Organization GUID"     = "c9b54579-7056-46c3-9870-334330e9be75"
    "Organization name"     = "smoke-test"
    "Service plan name"     = "micro-psql"
    "client"                = "Cloud Foundry"
    "Space GUID"            = "5db8fd06-ac53-4ed0-a224-b0bad2e463d2"
    "broker"                = "AWS broker"
    "Space name"            = "cloudwatch"
    "Created at"            = "2024-12-20T19:08:54Z"
    "Instance GUID"         = "024d7b3a-1732-4ae4-9e2a-f36eaa2c741c"
  })
}

resource "aws_cloudwatch_log_subscription_filter" "test_subscription" {
  for_each        = toset(var.environments)
  name            = "/aws/rds/instance/cg-aws-broker-${local.prefixes[each.key]}-smoketestenvironment"
  log_group_name  = aws_cloudwatch_log_group.test_log[each.key].name
  filter_pattern  = ""
  destination_arn = aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].arn
  role_arn        = resource.aws_iam_role.cloudwatch_role[each.key].arn
}