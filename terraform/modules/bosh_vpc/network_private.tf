/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  private_cidr_1
 *  private_cidr_2
 *  nat_gateway_instance_type
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "az1_private" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (Private AZ1)"
  }
}

resource "aws_subnet" "az2_private" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.private_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (Private AZ2)"
  }
}

resource "aws_route_table" "az1_private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Private Route Table AZ1)"
  }
}

resource "aws_route_table" "az2_private_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Private Route Table AZ2)"
  }
}

resource "aws_route_table_association" "az1_private_rta" {
  subnet_id      = aws_subnet.az1_private.id
  route_table_id = aws_route_table.az1_private_route_table.id
}

resource "aws_route_table_association" "az2_private_rta" {
  subnet_id      = aws_subnet.az2_private.id
  route_table_id = aws_route_table.az2_private_route_table.id
}


# With Firewall
# NAT gateways need their own subnet to prevent circular routing through the firewall.
# They need their own route table, hence a separate subnet.
resource "aws_subnet" "az1_nat" {
  count             = var.create_network_firewall ? 1 : 0
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.nat_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (NAT AZ1)"
  }
}

resource "aws_subnet" "az2_nat" {
  count             = var.create_network_firewall ? 1 : 0
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.nat_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (NAT AZ2)"
  }
}

# Common
resource "aws_eip" "az1_nat_eip" {
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "az2_nat_eip" {
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "az1_private_nat_service" {
  allocation_id = aws_eip.az1_nat_eip.id
  subnet_id     = var.create_network_firewall ? aws_subnet.az1_nat[0].id : aws_subnet.az1_public[0].id

  tags = {
    Name = "Nat Service AZ1 ${var.stack_description}"
  }
}

resource "aws_nat_gateway" "az2_private_nat_service" {
  allocation_id = aws_eip.az2_nat_eip.id
  subnet_id     = var.create_network_firewall ? aws_subnet.az2_nat[0].id : aws_subnet.az2_public[0].id

  tags = {
    Name = "Nat Service AZ2 ${var.stack_description}"
  }
}

# Without Firewall
resource "aws_route" "az1_nat_service_route" {
  count                  = var.create_network_firewall ? 0 : 1
  route_table_id         = aws_route_table.az1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az1_private_nat_service.id
}

resource "aws_route" "az2_nat_service_route" {
  count                  = var.create_network_firewall ? 0 : 1
  route_table_id         = aws_route_table.az2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2_private_nat_service.id
}


# With firewall
# Private subnet -> Primary firewall endpoint (egress)
resource "aws_route" "az1_private_egress" {
  route_table_id         = aws_route_table.az1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoints[var.az1]
}
resource "aws_route" "az2_private_egress" {
  route_table_id         = aws_route_table.az2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.firewall_endpoints[var.az2]
}

resource "aws_route_table" "az1_nat_route_table" {
  count  = var.create_network_firewall ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (NAT Route Table AZ1)"
  }
}

resource "aws_route_table" "az2_nat_route_table" {
  count  = var.create_network_firewall ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (NAT Route Table AZ2)"
  }
}

resource "aws_route_table_association" "az1_nat_rta" {
  count          = var.create_network_firewall ? 1 : 0
  subnet_id      = aws_subnet.az1_nat[0].id
  route_table_id = aws_route_table.az1_nat_route_table[0].id
}

resource "aws_route_table_association" "az2_nat_rta" {
  count          = var.create_network_firewall ? 1 : 0
  subnet_id      = aws_subnet.az2_nat[0].id
  route_table_id = aws_route_table.az2_nat_route_table[0].id
}

# NAT return -> Primary firewall endpoint -> Private subnet
resource "aws_route" "az1_nat_to_private" {
  count                  = var.create_network_firewall ? 1 : 0
  route_table_id         = aws_route_table.az1_nat_route_table[0].id
  destination_cidr_block = var.private_cidr_1
  vpc_endpoint_id        = local.firewall_endpoints[var.az1]
}

resource "aws_route" "az2_nat_to_private" {
  count                  = var.create_network_firewall ? 1 : 0
  route_table_id         = aws_route_table.az2_nat_route_table[0].id
  destination_cidr_block = var.private_cidr_2
  vpc_endpoint_id        = local.firewall_endpoints[var.az2]
}
