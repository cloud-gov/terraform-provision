resource "aws_lambda_function" "transform" {
  for_each = toset(var.environments)

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-${each.key}-transform"
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = "transform_lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.13"
  architectures    = ["arm64"]

  timeout = 60

  environment {
    variables = {
      ENVIRONMENT = each.key
      ACCOUNT_ID  = var.account_id
    }
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "http" "lambda_python" {
  url = "https://raw.githubusercontent.com/cloud-gov/aws_metrics_opensearch_preprocessor/refs/tags/v0.0.4/lambda_functions/transform_cloudwatch_lambda.py"
}

data "archive_file" "lambda_zip" {
  type = "zip"
  source {
    content  = data.http.lambda_python.response_body
    filename = "transform_lambda.py"
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

data "http" "cloudwatch_lambda_python" {
  url = "https://raw.githubusercontent.com/cloud-gov/aws_opensearch_preprocess_lambdas/refs/heads/main/lambda_functions/add_cloudwatch_subscrition.py"
}

data "archive_file" "cloudwatch_lambda_zip" {
  type = "zip"
  source {
    content  = data.http.cloudwatch_lambda_python.response_body
    filename = "cloudwatch_lambda.py"
  }
  output_path = "${path.module}/cloudwatch_lambda.zip"
}