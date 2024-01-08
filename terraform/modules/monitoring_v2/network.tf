/*
 * Variables required:
 *  stack_description
 *  monitoring_availability_zones
 *  monitoring_cidrs
 *  route_table_ids
 *  vpc_id
 *
 */

resource "aws_subnet" "monitoring_subnet" {
  count = length(var.monitoring_availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.monitoring_cidrs[count.index]
  availability_zone = var.monitoring_availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (Monitoring - ${var.monitoring_cidrs[count.index]})"
  }
}

resource "aws_route_table_association" "monitoring_rta" {
  count = length(var.monitoring_availability_zones)

  subnet_id      = aws_subnet.monitoring_subnet[count.index].id
  route_table_id = var.route_table_ids[count.index]
}

