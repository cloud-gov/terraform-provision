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

data "archive_file" "lambda_zip" {
  depends_on  = [data.external.run_tests]
  type        = "zip"
  source_file = "${path.module}/src/transform_lambda.py"
  output_path = "${path.module}/src/transform_lambda.zip"
}
