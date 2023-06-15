/*
 * Variables required:
 *  stack_description
 *  availability_zones
 *  private_cidrs
 *  nat_gateway_instance_type
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "subnet_private" {
  count             = length(var.availability_zones)

  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.stack_description} (Private AZ${count.index + 1})"
  }
}

resource "aws_route_table" "private_route_table" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Private Route Table AZ${count.index + 1})"
  }
}

resource "aws_route_table_association" "private_rta" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.subnet_private[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_route" "azs_nat_service_route" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.private_route_table[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.private_nat_service[count.index].id
}

resource "aws_eip" "private_nat_eip" {
  count = length(var.availability_zones)
  vpc   = true
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "private_nat_service" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.private_nat_eip[count.index].id
  subnet_id     = aws_subnet.subnet_public[count.index].id

  tags = {
    Name = "Nat Service AZ${count.index + 1} ${var.stack_description}"
  }
}


