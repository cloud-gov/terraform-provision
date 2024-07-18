resource "aws_iam_policy" "read_only_access_restrictions" {
  name        = "ReadOnlyAccessRestrictions"
  description = "Use in combination with Amazon managed ReadOnlyAccess policy."

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "ReadOnlyAccessRestrictions",
      "Effect": "Deny",
      "Action": [
        "cloudformation:GetTemplate",
        "dynamodb:GetItem",
        "dynamodb:BatchGetItem",
        "dynamodb:Query",
        "dynamodb:Scan",
        "kinesis:Get*",
        "lambda:GetFunction",
        "s3:GetObject",
        "sdb:Select*",
        "sqs:ReceiveMessage"
      ],
      "Resource": "*"
    }
  ]
}
EOF

}
