
resource "aws_s3_bucket" "log_bucket" {
  bucket        = "${var.stack_description}-platform-logs"
  acl           = "private"

  lifecycle_rule {
    prefix  = ""
    enabled = true
    transition {
      days          = 180
      storage_class = "ONEZONE_IA"
    }
    expiration {
      days = 365
    }
  }
}


data "template_file" "policy" {
  template = file("${path.module}/policy.json")
  vars = {
    aws_partition = var.aws_partition
    bucket_name   = aws_s3_bucket.log_bucket.id
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
  policy = data.template_file.policy.rendered
}

