resource "aws_sqs_queue" "object_created_queue" {
  count                      = var.enable_sqs_notification ? 1 : 0
  name                       = "${var.bucket}-object-created"
  message_retention_seconds  = var.sqs_message_retention_seconds
  visibility_timeout_seconds = var.sqs_visibility_timeout_seconds
  sqs_managed_sse_enabled    = true
}

data "aws_iam_policy_document" "object_created_queue_policy" {
  count = var.enable_sqs_notification ? 1 : 0

  statement {
    sid     = "AllowS3Publish"
    effect  = "Allow"
    actions = ["sqs:SendMessage"]

    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }

    resources = [aws_sqs_queue.object_created_queue[0].arn]

    condition {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = [aws_s3_bucket.log_encrypted_bucket.arn]
    }
  }
}

resource "aws_sqs_queue_policy" "object_created_queue_policy" {
  count     = var.enable_sqs_notification ? 1 : 0
  queue_url = aws_sqs_queue.object_created_queue[0].id
  policy    = data.aws_iam_policy_document.object_created_queue_policy[0].json
}

resource "aws_s3_bucket_notification" "object_created_notification" {
  count  = var.enable_sqs_notification ? 1 : 0
  bucket = aws_s3_bucket.log_encrypted_bucket.id

  queue {
    queue_arn = aws_sqs_queue.object_created_queue[0].arn
    events    = ["s3:ObjectCreated:*"]
  }

  depends_on = [aws_sqs_queue_policy.object_created_queue_policy]
}
