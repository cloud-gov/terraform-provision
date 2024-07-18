/*
 * Variables required:
 *  stack_description
 *  concourse_availability_zones
 *  concourse_cidrs
 *  route_table_ids
 *  vpc_id
 *
 */

resource "aws_subnet" "concourse" {
  count = length(var.concourse_availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.concourse_cidrs[count.index]
  availability_zone = var.concourse_availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (Concourse - ${var.concourse_cidrs[count.index]})"
  }
}

resource "aws_route_table_association" "concourse_rta" {
  count = length(var.concourse_availability_zones)

  subnet_id      = aws_subnet.concourse[count.index].id
  route_table_id = var.route_table_ids[count.index]
}
