/*
 * Variables required:
 *  stack_description
 *  concourse_az
 *  concourse_cidr
 *  route_table_id
 *  vpc_id
 *
 */

resource "aws_subnet" "concourse" {
  vpc_id            = var.vpc_id
  cidr_block        = var.concourse_cidr
  availability_zone = var.concourse_az

  tags = {
    Name = "${var.stack_description} (Concourse - ${var.concourse_cidr})"
  }
}

resource "aws_route_table_association" "concourse_rta" {
  subnet_id      = aws_subnet.concourse.id
  route_table_id = var.route_table_id
}


resource "aws_subnet" "concourse_az2" {
  vpc_id            = var.vpc_id
  cidr_block        = var.concourse_cidr_az2
  availability_zone = var.concourse_az2

  tags = {
    Name = "${var.stack_description} (Concourse - ${var.concourse_cidr_az2})"
  }
}

resource "aws_route_table_association" "concourse_rta_az2" {
  subnet_id      = aws_subnet.concourse_az2.id
  route_table_id = var.route_table_id_az2
}
