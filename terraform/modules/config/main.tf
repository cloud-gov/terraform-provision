module "config_results_bucket" {
  source = "../s3_bucket/log_encrypted_bucket"
  bucket          = "${var.stack_prefix}-config-results"
  aws_partition   = var.aws_partition
  expiration_days = 930 # 31 days * 30 months = 930 days
}

resource "aws_iam_role" "aws_config_role" {
  name = "${var.stack_prefix}-config-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "config.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy" "p" {
  name = "${stack_prefix}-config-bucket-access-policy"
  role = aws_iam_role.r.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:*"
      ],
      "Effect": "Allow",
      "Resource": [
        "${module.config_results_bucket.bucket_arn}",
        "${module.config_results_bucket.bucket_arn}/*"
      ]
    }
  ]
}
POLICY
}

resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.stack_prefix}-config-recorder"
  role_arn = aws_iam_role.aws_config_role.arn
}

resource "aws_config_delivery_channel" "s3_delivery" {
  depends_on     = [aws_config_configuration_recorder.recorder]
  name           = "${var.stack_descstack_prefixription}-config-delivery"
  s3_bucket_name = module.config_results_bucket.bucket_name
}

