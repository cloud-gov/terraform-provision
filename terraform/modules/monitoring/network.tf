/*
 * Variables required:
 *  stack_description
 *  monitoring_az
 *  monitoring_cidr
 *  route_table_id
 *  vpc_id
 *
 */

resource "aws_subnet" "monitoring" {
  vpc_id            = var.vpc_id
  cidr_block        = var.monitoring_cidr
  availability_zone = var.monitoring_az

  tags = {
    Name = "${var.stack_description} (Monitoring - ${var.monitoring_cidr})"
  }
}

resource "aws_route_table_association" "monitoring_rta" {
  subnet_id      = aws_subnet.monitoring.id
  route_table_id = var.route_table_id
}
