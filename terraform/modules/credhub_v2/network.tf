resource "aws_subnet" "credhub_subnet" {
  count             = length(var.credhub_availability_zones)

  vpc_id            = var.vpc_id
  cidr_block        = var.credhub_cidrs[count.index]
  availability_zone = var.credhub_availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (Credhub - ${var.credhub_availability_zones[count.index]})"
  }
}

resource "aws_route_table_association" "credhub_rta" {
  count          = length(var.credhub_availability_zones)

  subnet_id      = aws_subnet.credhub_subnet[count.index].id
  route_table_id = var.route_table_ids[count.index]
}
