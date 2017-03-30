resource "aws_iam_role" "iam_role" {
  name = "${var.role_name}"
  path = "${var.role_path}"
  assume_role_policy = "${var.iam_assume_role_policy}"
}

resource "aws_iam_instance_profile" "iam_profile" {
  name = "${var.role_name}"
  roles = ["${aws_iam_role.iam_role.name}"]
}

resource "aws_iam_policy" "iam_policy" {
  count = "${var.iam_policy != "" ? 1 : 0}"
  name = "${var.role_name}"
  policy = "${var.iam_policy}"
  role = "${aws_iam_role.iam_role.name}"
}

resource "aws_iam_policy_attachment" "iam_policy_attachment" {
  count = "${length(var.iam_policies)}"
  name = "${element(var.iam_policies, count.index)}"
  role = "${aws_iam_role.iam_role.name}"
}
