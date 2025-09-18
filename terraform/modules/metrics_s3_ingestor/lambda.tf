resource "aws_lambda_function" "transform" {
  for_each = toset(var.environments)

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.name_prefix}-${each.key}-transform"
  role             = aws_iam_role.lambda_role[each.key].arn
  handler          = "transform_lambda.lambda_handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime          = "python3.13"
  architectures    = ["arm64"]

  timeout = 10

  environment {
    variables = {
      ENVIRONMENT = each.key
    }
  }

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

data "http" "lambda_python" {
  url = "https://github.com/cloud-gov/aws_metrics_opensearch_preprocessor/blob/v0.0.1/lambda_functions/transform_lambda.py"
}

resource "local_file" "lambda_python_file" {
  content  = data.http.lambda_python.response_body
  filename = "${path.module}/transform_lambda.py"
}

data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = data.local_file.lambda_python_file.filename
  output_path = "${path.module}/transform_lambda.zip"
}
