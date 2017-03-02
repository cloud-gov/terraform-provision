output "username" {
  value = "${var.username}"
}
output "access_key_id_prev" {
  value = "${aws_iam_access_key.iam_access_key.id}"
}
output "secret_access_key_prev" {
  value = "${aws_iam_access_key.iam_access_key.secret}"
}
output "access_key_id_curr" {
  value = "${aws_iam_access_key.iam_access_key_v1.id}"
}
output "secret_access_key_curr" {
  value = "${aws_iam_access_key.iam_access_key_v1.secret}"
}
