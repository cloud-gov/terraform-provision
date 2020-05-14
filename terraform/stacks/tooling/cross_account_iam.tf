resource "aws_iam_role" "payer_account_access" {
    name = "payer-account-access"

    assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Principal": {
            "AWS": "arn:aws:iam::${var.payer_account_id}:root"
          },
          "Action": "sts:AssumeRole",
          "Condition": {
            "Bool": {
              "aws:MultiFactorAuthPresent": "true"
            }
          }
        }
      ]
    }
    EOF
}

resource "aws_iam_policy" "read_s3_tags" {
    name = "read-s3-bucket-tags"
    description = "Allow reading bucket tags in s3"

    policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Effect": "Allow",
          "Action": "s3:ListAllMyBuckets",
          "Resource": "*"
        },
        {
          "Effect": "Allow",
          "Action": [
            "s3:GetBucketLocation",
            "s3:GetBucketTagging"
           ],
          "Resource": "arn:aws:s3:::*"
        }
      ]
    }
    EOF
}

resource "aws_iam_role_policy_attachment" "payer_read_s3_tags" {
    role = "payer-account-access"
    policy = "read-s3-bucket-tags"
}
