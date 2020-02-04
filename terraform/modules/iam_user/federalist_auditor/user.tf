# This user has access to all cloudtrail events in the account, as there
# doesn't seem to be a way of constraining to just cloudfront events relevant
# to a set of S3 buckets (or all S3 buckets, for that matter).
#
# If you need cloudtrail auditor access for another reason, PLEASE CREATE A NEW
# USER AND MODULE (yes, even with the same permissions).  Having separate users
# with the same permissions simplifies our work when we have to rotate
# credentials.

resource "aws_iam_user" "iam_user" {
  name = "${var.username}"
}

resource "aws_iam_access_key" "iam_access_key_v3" {
  user = "${aws_iam_user.iam_user.name}"
}

resource "aws_iam_user_policy" "iam_policy" {
  name = "${aws_iam_user.iam_user.name}-policy"
  user = "${aws_iam_user.iam_user.name}"
  policy = "${file("${path.module}/policy.json")}"
}
