locals {
  common_tags = merge(
    var.tags,
    {
      Module = "metric_processing_lambda"
    }
  )
}

# Run pytest tests as a validation step
resource "null_resource" "run_pytest" {
  triggers = {
    # Re-run tests when source code or tests change
    source_code_hash = filemd5("${path.module}/src/transform_lambda.py")
    test_code_hash   = filemd5("${path.module}/tests/test_transform_lambda.py")
    timestamp        = timestamp()
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Installing test dependencies..."
      python -m pip install -r requirements-dev.txt

      echo "Running pytest..."
      python -m pytest tests/ -v --tb=short

      if [ $? -eq 0 ]; then
        echo "All tests passed!"
      else
        echo "Tests failed!"
        exit 1
      fi
    EOT
  }
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
    metric_names = ["CPUUtilization",
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

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}
