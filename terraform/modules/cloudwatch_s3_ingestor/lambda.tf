locals {
  # Every file packaged into the Lambda zips is fetched at this tag. All of the
  # URLs below must move together: the handler and the shared partitioning
  # module are deployed as one unit, so a half-bumped tag ships a handler
  # against a mismatched org_partitioning.py.
  lambda_source_tag      = "v0.1.2"
  lambda_source_base_url = "https://raw.githubusercontent.com/cloud-gov/aws_opensearch_preprocess_lambdas/refs/tags/${local.lambda_source_tag}/lambda_functions"
}

resource "aws_lambda_function" "transform" {
  for_each = toset(var.environments)

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-${each.key}-transform"
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = "transform_lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.13"
  architectures    = ["arm64"]
  memory_size      = 300

  timeout = 60

  publish = true

  environment {
    variables = {
      ENVIRONMENT    = each.key
      ACCOUNT_ID     = var.account_id
      S3_BUCKET_NAME = resource.aws_s3_bucket.opensearch_cloudwatch_buckets[each.key].bucket
    }
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "http" "lambda_python" {
  url = "${local.lambda_source_base_url}/transform_cloudwatch_lambda.py"
}

# Shared with the metrics_s3_ingestor module's transform Lambda. The handler
# imports it as a top-level `org_partitioning`, so it has to land at the root of
# the zip under exactly this name.
data "http" "org_partitioning_python" {
  url = "${local.lambda_source_base_url}/org_partitioning.py"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source {
    content  = data.http.lambda_python.response_body
    filename = "transform_lambda.py"
  }
  source {
    content  = data.http.org_partitioning_python.response_body
    filename = "org_partitioning.py"
  }
  output_path = "${path.module}/transform_lambda.zip"
}


resource "aws_lambda_function" "cloudwatch_filter" {
  for_each = toset(var.environments)

  filename         = data.archive_file.cloudwatch_lambda_zip.output_path
  function_name    = "${var.name_prefix}-${each.key}-cloudwatch"
  role             = aws_iam_role.cloudwatch_lambda_role[each.key].arn
  handler          = "cloudwatch_lambda.lambda_handler"
  source_code_hash = data.archive_file.cloudwatch_lambda_zip.output_base64sha256
  runtime          = "python3.13"
  architectures    = ["arm64"]

  timeout = 60

  environment {
    variables = {
      FIREHOSE_ARN = resource.aws_kinesis_firehose_delivery_stream.cloudwatch_stream[each.key].arn
      ROLE_ARN     = resource.aws_iam_role.cloudwatch_role[each.key].arn
      ENVIRONMENT  = each.key
    }
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

# The subscription manager shares no code with the transform Lambdas, so it
# stays a single-file zip.
data "http" "cloudwatch_lambda_python" {
  url = "${local.lambda_source_base_url}/add_cloudwatch_subscrition.py"
}

data "archive_file" "cloudwatch_lambda_zip" {
  type = "zip"
  source {
    content  = data.http.cloudwatch_lambda_python.response_body
    filename = "cloudwatch_lambda.py"
  }
  output_path = "${path.module}/cloudwatch_lambda.zip"
}
