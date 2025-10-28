# EventBridge IAM resources
resource "aws_iam_role" "eventbridge_lambda_role" {
  for_each = toset(var.environments)
  name = "${var.name_prefix}-${each.key}-eventbridge-lambda-role" 
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect   = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eventbridge_lambda_policy" {
  for_each = toset(var.environments)
  name        = "${var.name_prefix}-${each.key}-eventbridge-lambda-policy"
  description = "Policy for EventBridge to invoke Lambda"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "lambda:InvokeFunction"
        Effect   = "Allow"
        Resource =[aws_lambda_function.cloudwatch_filter[each.key].arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eventbridge_lambda_attachment" {
  for_each = toset(var.environments)
  role       = aws_iam_role.eventbridge_lambda_role[each.key].name
  policy_arn = aws_iam_policy.eventbridge_lambda_policy[each.key].arn
}