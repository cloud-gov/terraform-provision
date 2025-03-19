resource "aws_subnet" "defectdojo_az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.defectdojo_cidr_az1
  availability_zone = var.defectdojo_az1

  tags = {
    Name = "${var.stack_description} (Defect Dojo - ${var.defectdojo_cidr_az1})"
  }
}

resource "aws_subnet" "defectdojo_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.defectdojo_cidr_az2
  availability_zone = var.defectdojo_az2

  tags = {
    Name = "${var.stack_description} (Defect Dojo - ${var.defectdojo_cidr_az2})"
  }
}

resource "aws_route_table_association" "defectdojo_rta_az1" {
  subnet_id      = aws_subnet.defectdojo_az1.id
  route_table_id = var.route_table_id_az1
}

resource "aws_route_table_association" "defectdojo_rta_az2" {
  subnet_id      = aws_subnet.defectdojo_az2.id
  route_table_id = var.route_table_id_az2
}
