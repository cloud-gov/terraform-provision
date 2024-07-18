resource "aws_key_pair" "bosh" {
  key_name   = "${var.stack_description}-key"
  public_key = var.bosh_default_ssh_public_key
}