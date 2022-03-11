locals {
  # https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-access-logs.html#access-logging-bucket-permissions
  aws_alb_account_ids = {
    us-east-1      = "127311923021"
    us-east-2      = "033677994240"
    us-west-1      = "027434742980"
    us-west-2      = "797873946194"
    ca-central-1   = "985666609251"
    eu-central-1   = "054676820928"
    eu-west-1      = "156460612806"
    eu-west-2      = "652711504416"
    eu-west-3      = "009996457667"
    eu-north-1     = "897822967062"
    ap-east-1      = "754344448648"
    ap-northeast-1 = "582318560864"
    ap-northeast-2 = "600734575887"
    ap-northeast-3 = "383597477331"
    ap-southeast-1 = "114774131450"
    ap-southeast-2 = "783225319266"
    ap-south-1     = "718504428378"
    sa-east-1      = "507241528517"
    us-gov-west-1  = "048591011584"
    us-gov-east-1  = "190560391635"
    cn-north-1     = "638102146993"
    cn-northwest-1 = "037604701340"
  }
}

resource "aws_s3_bucket" "log_bucket" {
  bucket        = var.log_bucket_name
  force_destroy = var.log_bucket_force_destroy
}

resource "aws_s3_bucket_acl" "log_bucket_acl" {
  bucket        = aws_s3_bucket.log_bucket.id
  acl           = var.log_bucket_acl
}
resource "aws_s3_bucket_lifecycle_configuration" "log_bucket_lifecycle" {
  bucket = aws_s3_bucket.log_bucket.id
  rule {
    id = "all"
    filter {
      prefix  = ""
    }
    status = "Enabled"
    transition {
      days          = 90
      storage_class = "ONEZONE_IA"
    }
    expiration {
      days = 180
    }
  }
}
resource "aws_s3_bucket_policy" "log_bucket_policy" {
  bucket = aws_s3_bucket.log_bucket.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:${var.aws_partition}:iam::${local.aws_alb_account_ids[var.aws_region]}:root"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws-us-gov:s3:::${var.log_bucket_name}/*"
        }
    ]
}
EOF

}

