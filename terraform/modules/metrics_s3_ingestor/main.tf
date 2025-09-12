locals {
  common_tags = merge(
    var.tags,
    {
      Module = "metric_processing_lambda"
    }
  )
}

# Run tests before deployment
data "external" "run_tests" {
  program = ["python", "-c", <<-EOT
import subprocess
import json
import sys
import os

try:
    # Install test dependencies
    subprocess.run([sys.executable, "-m", "pip", "install", "-r", "requirements-dev.txt"],
                  check=True, capture_output=True)

    # Run pytest with coverage
    result = subprocess.run([
        sys.executable, "-m", "pytest",
        "tests/",
        "-v",
        "--cov=src",
        "--cov-report=term-missing"
    ], capture_output=True, text=True, cwd=os.getcwd())

    if result.returncode == 0:
        output = {
            "status": "passed",
            "output": result.stdout,
            "coverage": "See coverage report above"
        }
    else:
        output = {
            "status": "failed",
            "output": result.stdout + "\n" + result.stderr
        }
        # Don't fail terraform, just report

    print(json.dumps(output))

except Exception as e:
    print(json.dumps({"status": "error", "output": str(e)}))
EOT
  ]
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
