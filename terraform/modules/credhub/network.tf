resource "aws_subnet" "credhub_az1" {
  vpc_id            = var.vpc_id
  cidr_block        = var.credhub_cidr_az1
  availability_zone = var.credhub_az1

  tags = {
    Name = "${var.stack_description} (Credhub - ${var.credhub_cidr_az1})"
  }
}

resource "aws_subnet" "credhub_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.credhub_cidr_az2
  availability_zone = var.credhub_az2

  tags = {
    Name = "${var.stack_description} (Credhub - ${var.credhub_cidr_az2})"
  }
}

resource "aws_route_table_association" "credhub_rta_az1" {
  subnet_id      = aws_subnet.credhub_az1.id
  route_table_id = var.route_table_id_az1
}

resource "aws_route_table_association" "credhub_rta_az2" {
  subnet_id      = aws_subnet.credhub_az2.id
  route_table_id = var.route_table_id_az2
}
