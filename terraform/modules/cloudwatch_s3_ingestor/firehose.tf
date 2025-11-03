resource "aws_cloudwatch_log_group" "firehose_log_group" {
  for_each          = toset(var.environments)
  name              = "/aws/kinesisfirehose/${var.name_prefix}-${each.key}-delivery-stream"
  retention_in_days = 14

  tags = merge(local.common_tags, {
    Environment = each.key
  })
}

resource "aws_cloudwatch_log_stream" "firehose_log_stream" {
  for_each       = toset(var.environments)
  name           = "DestinationForDelivery"
  log_group_name = aws_cloudwatch_log_group.firehose_log_group[each.key].name
}

resource "aws_kinesis_firehose_delivery_stream" "cloudwatch_stream" {
  for_each = toset(var.environments)

  name        = "${var.name_prefix}-${each.key}-delivery-stream"
  destination = "extended_s3"



  extended_s3_configuration {
    role_arn            = aws_iam_role.firehose_role[each.key].arn
    bucket_arn          = aws_s3_bucket.opensearch_cloudwatch_buckets[each.key].arn
    buffering_size      = var.firehose_buffer_size
    buffering_interval  = var.firehose_buffer_interval
    compression_format  = "GZIP"
    prefix              = "!{timestamp:yyyy}/!{timestamp:MM}/!{timestamp:dd}/!{timestamp:HH}/!{timestamp:mm}/"
    error_output_prefix = "errors/"

    processing_configuration {
      enabled = true
      processors {
        type = "Lambda"

        parameters {
          parameter_name  = "LambdaArn"
          parameter_value = "${aws_lambda_function.transform[each.key].arn}:$LATEST"
        }

        parameters {
          parameter_name  = "BufferSizeInMBs" # Controls Lambda batch size
          parameter_value = "0.1"               
        }
        parameters {
          parameter_name  = "BufferIntervalInSeconds"
          parameter_value = "60"
        }

      }
    }
    cloudwatch_logging_options {
      enabled         = true
      log_group_name  = aws_cloudwatch_log_group.firehose_log_group[each.key].name
      log_stream_name = aws_cloudwatch_log_stream.firehose_log_stream[each.key].name
    }

  }
  tags = merge(local.common_tags, {
    Environment = each.key
  })
}
