resource "aws_subnet" "defectdojo" {
  vpc_id            = var.vpc_id
  cidr_block        = var.defectdojo_cidr
  availability_zone = var.defectdojo_az

  tags = {
    Name = "${var.stack_description} (Defect Dojo - ${var.defectdojo_cidr})"
  }
}

resource "aws_route_table_association" "defectdojo_rta" {
  subnet_id      = aws_subnet.defectdojo.id
  route_table_id = var.route_table_id
}
