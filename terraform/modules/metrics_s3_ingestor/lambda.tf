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

data "archive_file" "lambda_zip" {
  depends_on  = [resource.null_resource.run_pytest]
  type        = "zip"
  source_file = "${path.module}/src/transform_lambda.py"
  output_path = "${path.module}/src/transform_lambda.zip"
}
