
resource "aws_s3_bucket" "cdn_broker_le" {
    bucket = "cdn-broker-le-verify"
    policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AddPerm",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::cdn-broker-le-verify/*"
        }
    ]
}
EOF
}
