resource "aws_s3_bucket" "cc-resoures" {
    bucket = "${var.stack_prefix}-cc-resources"
    acl = "private"
}

resource "aws_s3_bucket" "buildpacks" {
    bucket = "${var.stack_prefix}-buildpacks"
    acl = "private"
}

resource "aws_s3_bucket" "cc-packages" {
    bucket = "${var.stack_prefix}-cc-packages"
    acl = "private"
}

resource "aws_s3_bucket" "cc-resoures" {
    bucket = "${var.stack_prefix}-droplets"
    acl = "private"
}
