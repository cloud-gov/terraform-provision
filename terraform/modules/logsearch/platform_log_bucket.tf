
resource "aws_s3_bucket" "log_bucket" {
  bucket = "${var.stack_description}-platform-logs"
}
resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket = aws_s3_bucket.log_bucket.id
  acl    = "private"
}
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    id     = "all"
    status = "Enabled"
    transition {
      days          = 365
      storage_class = "ONEZONE_IA"
    }
    expiration {
      days = 930 # 31 days * 30 months = 930 days
    }
  }
  transition_default_minimum_object_size = "varies_by_storage_class"
}

data "aws_iam_policy_document" "platform_log_bucket_user_policy" {
  statement {
    actions = [
      "s3:PutObject"
    ]

    resources = [
      "arn:${var.aws_partition}:s3:::${aws_s3_bucket.log_bucket.id}/*"
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  name = "${var.stack_description}-platform-logs"
}

resource "aws_iam_access_key" "iam_access_key_v1" {
  user = aws_iam_user.iam_user.name
}

resource "aws_iam_user_policy" "iam_policy" {
  name   = "${aws_iam_user.iam_user.name}-policy"
  user   = aws_iam_user.iam_user.name
  policy = data.aws_iam_policy_document.platform_log_bucket_user_policy.json
}
