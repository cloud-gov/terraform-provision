locals {
  common_tags = merge(
    var.tags,
    {
      Module = "metric_processing_lambda"
    }
  )
}

resource "aws_cloudwatch_metric_stream" "main" {
  for_each = toset(var.environments)

  name          = "${var.name_prefix}-${each.key}-stream"
  role_arn      = aws_iam_role.metric_stream_role[each.key].arn
  firehose_arn  = aws_kinesis_firehose_delivery_stream.metric_stream[each.key].arn
  output_format = "json"

  include_filter {
    namespace    = "AWS/S3"
    metric_names = ["BucketSizeBytes"]
  }

  include_filter {
    namespace = "AWS/ES"
    metric_names = [
      "CPUUtilization",
      "JVMMemoryPressure",
      "FreeStorageSpace",
      "OldGenJVMMemoryPressure",
      "MasterCPUUtilization",
      "MasterJVMMemoryPressure",
      "MasterOldGenJVMMemoryPressure",
      "ThreadpoolWriteQueue",
      "ThreadpoolSearchQueue",
      "ThreadpoolSearchRejected",
    "ThreadpoolWriteRejected"]
  }

  include_filter {
    namespace = "AWS/RDS"
    metric_names = [
      "CPUUtilization",
      "DatabaseConnections",
      "FreeStorageSpace",
      "ReadLatency",
      "WriteLatency"
    ]
  }

  include_filter {
    namespace = "AWS/ElastiCache
    metric_names = [
      "CPUUtilization"
    ]
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}
