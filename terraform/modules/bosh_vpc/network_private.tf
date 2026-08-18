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

# No network firewall
resource "aws_route" "az1_nat_service_route" {
  count                  = var.egress_traffic_through_inspection_vpc ? 0 : 1
  route_table_id         = aws_route_table.az1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az1_private_nat_service.id
}

resource "aws_route" "az2_nat_service_route" {
  count                  = var.egress_traffic_through_inspection_vpc ? 0 : 1
  route_table_id         = aws_route_table.az2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2_private_nat_service.id
}


resource "aws_eip" "az1_nat_eip" {
  count  = var.egress_traffic_through_inspection_vpc ? 0 : 1
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_eip" "az2_nat_eip" {
  count  = var.egress_traffic_through_inspection_vpc ? 0 : 1
  domain = "vpc"
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "az1_private_nat_service" {
  count         = var.egress_traffic_through_inspection_vpc ? 0 : 1
  allocation_id = aws_eip.az1_nat_eip.id
  subnet_id     = aws_subnet.az1_public.id

  tags = {
    Name = "Nat Service AZ1 ${var.stack_description}"
  }
}

resource "aws_nat_gateway" "az2_private_nat_service" {
  count         = var.egress_traffic_through_inspection_vpc ? 0 : 1
  allocation_id = aws_eip.az2_nat_eip.id
  subnet_id     = aws_subnet.az2_public.id

  tags = {
    Name = "Nat Service AZ2 ${var.stack_description}"
  }
}

# Egress through NFW inspection VPC
resource "aws_route" "private_network_egress_through_nfw_inspection_vpc_za1" {
  count                  = var.egress_traffic_through_inspection_vpc ? 1 : 0
  route_table_id         = aws_route_table.az1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.firewall-inspection-vpc.outputs.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main_vpc]
}

resource "aws_route" "private_network_egress_through_nfw_inspection_vpc_za2" {
  count                  = var.egress_traffic_through_inspection_vpc ? 1 : 0
  route_table_id         = aws_route_table.az2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  transit_gateway_id     = data.terraform_remote_state.firewall-inspection-vpc.outputs.transit_gateway_id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.main_vpc]
}
