resource "aws_key_pair" "auth" {
  public_key = "${file("${var.public_key_path}")}"
}