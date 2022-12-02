# https://docs.aws.amazon.com/config/latest/developerguide/access-keys-rotated.html
resource "aws_config_config_rule" "access_keys_rotated" {
  name = "${var.stack_prefix}-access-keys-rotated"

  source {
    owner             = "AWS"
    source_identifier = "ACCESS_KEYS_ROTATED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/acm-certificate-expiration-check.html
resource "aws_config_config_rule" "acm_certificate_expiration_check" {
  name = "${var.stack_prefix}-acm-certificate-expiration-check"

  source {
    owner             = "AWS"
    source_identifier = "ACM_CERTIFICATE_EXPIRATION_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/cloudtrail-enabled.html
resource "aws_config_config_rule" "cloud_trail_enabled" {
  name = "${var.stack_prefix}-cloudtrail-enabled"

  source {
    owner             = "AWS"
    source_identifier = "CLOUD_TRAIL_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/ebs-snapshot-public-restorable-check.html
resource "aws_config_config_rule" "ebs_snapshot_public_restorable_check" {
  name = "${var.stack_prefix}-ebs-snapshot-public-restorable-check"

  source {
    owner             = "AWS"
    source_identifier = "EBS_SNAPSHOT_PUBLIC_RESTORABLE_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/ec2-ebs-encryption-by-default.html
resource "aws_config_config_rule" "ec2_ebs_encryption_by_default" {
  name = "${var.stack_prefix}-ec2-ebs-encryption-by-default"

  source {
    owner             = "AWS"
    source_identifier = "EC2_EBS_ENCRYPTION_BY_DEFAULT"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/ec2-instance-no-public-ip.html
resource "aws_config_config_rule" "ec2_instance_no_public_ip" {
  name = "${var.stack_prefix}-ec2-instance-no-public-ip"

  source {
    owner             = "AWS"
    source_identifier = "EC2_INSTANCE_NO_PUBLIC_IP"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/iam-no-inline-policy-check.html
resource "aws_config_config_rule" "iam_no_inline_policy_check" {
  name = "${var.stack_prefix}-iam-no-inline-policy-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_NO_INLINE_POLICY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/iam-root-access-key-check.html
resource "aws_config_config_rule" "iam_root_access_key_check" {
  name = "${var.stack_prefix}-iam-root-access-key-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_ROOT_ACCESS_KEY_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/iam-user-group-membership-check.html
resource "aws_config_config_rule" "iam_user_group_membership_check" {
  name = "${var.stack_prefix}-iam-user-group-membership-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_GROUP_MEMBERSHIP_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/iam-user-no-policies-check.html
resource "aws_config_config_rule" "iam_user_no_policies_check" {
  name = "${var.stack_prefix}-iam-user-no-policies-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_NO_POLICIES_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/iam-user-unused-credentials-check.html
resource "aws_config_config_rule" "iam_user_unused_credentials_check" {
  name = "${var.stack_prefix}-iam-user-unused-credentials-check"

  source {
    owner             = "AWS"
    source_identifier = "IAM_USER_UNUSED_CREDENTIALS_CHECK"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-public-read-prohibited.html
resource "aws_config_config_rule" "s3_bucket_public_read_prohibited" {
  name = "${var.stack_prefix}-s3-bucket-public-read-prohibited"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_PUBLIC_READ_PROHIBITED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/s3-bucket-server-side-encryption-enabled.html
resource "aws_config_config_rule" "s3_bucket_server_side_encryption_enabled" {
  name = "${var.stack_prefix}-s3-bucket-server-side-encryption-enabled"

  source {
    owner             = "AWS"
    source_identifier = "S3_BUCKET_SERVER_SIDE_ENCRYPTION_ENABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}

# https://docs.aws.amazon.com/config/latest/developerguide/vpc-default-security-group-closed.html
resource "aws_config_config_rule" "vpc_default_security_group_closed" {
  name = "${var.stack_prefix}-vpc-default-security-group-closed"

  source {
    owner             = "AWS"
    source_identifier = "VPC_DEFAULT_SECURITY_GROUP_CLOSED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}