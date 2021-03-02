resource "aws_subnet" "credhub" {
  vpc_id            = var.vpc_id
  cidr_block        = var.credhub_cidr
  availability_zone = var.credhub_az

  tags = {
    Name = "${var.stack_description} (Credhub - ${var.credhub_cidr})"
  }
}

resource "aws_route_table_association" "credhub_rta" {
  subnet_id      = aws_subnet.credhub.id
  route_table_id = var.route_table_id
}

