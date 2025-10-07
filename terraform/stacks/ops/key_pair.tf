resource "tls_private_key" "bosh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_bosh_key" {
  key_name   = var.stack_description
  public_key = tls_private_key.bosh_key.public_key_openssh
}
