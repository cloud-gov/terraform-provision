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

/*
 * Private default routes.
 *
 * The resource names remain "nat_service_route" because renaming them would
 * change their addresses in state, and Terraform would then destroy and recreate
 * the default route of a live VPC -- a total egress outage for that subnet.
 * Switching the target in place on the same address
 * updates the existing route instead.
 *
 * Note what this does NOT make safe: moving egress to the inspection VPC changes
 * the source address external services see, from this VPC's NAT EIPs to the
 * inspection VPC's. Established outbound TCP connections reset. No amount of
 * dependency ordering prevents that; see README.md.
 */
resource "aws_route" "az1_nat_service_route" {
  route_table_id         = aws_route_table.az1_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = local.inspection_enabled ? null : aws_nat_gateway.az1_private_nat_service.id
  transit_gateway_id     = local.inspection_enabled ? local.inspection_transit_gateway_id : null

  # This orders Terraform's API calls. It does not wait for TGW route
  # propagation to converge, which happens after the API returns and which
  # Terraform cannot observe.
  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.main_vpc,
    aws_ec2_transit_gateway_route_table_association.main_vpc,
    aws_ec2_transit_gateway_route.main_vpc_egress_to_inspection,
    aws_ec2_transit_gateway_route_table_propagation.main_vpc_to_inspection,
  ]
}

resource "aws_route" "az2_nat_service_route" {
  route_table_id         = aws_route_table.az2_private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = local.inspection_enabled ? null : aws_nat_gateway.az2_private_nat_service.id
  transit_gateway_id     = local.inspection_enabled ? local.inspection_transit_gateway_id : null

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.main_vpc,
    aws_ec2_transit_gateway_route_table_association.main_vpc,
    aws_ec2_transit_gateway_route.main_vpc_egress_to_inspection,
    aws_ec2_transit_gateway_route_table_propagation.main_vpc_to_inspection,
  ]
}

/*
 * NAT gateways and their EIPs remain regardless of routing through the inspection
 * vpc.
 *
 *  - The nat_egress_ip_az1/az2 outputs are consumed elsewhere, and downstream
 *    allowlists are keyed on those addresses. Releasing an EIP does not get the
 *    same address back.
 *  - Rollback is possible. Flipping the flag back restores the
 *    pre-inspection egress path with its original addresses and no new
 *    allowlist coordination.
 *
 * Removing them is a separate
 * deliberate change, once inspection has been proven in an environment.
 */
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
  subnet_id     = aws_subnet.az1_public.id

  tags = {
    Name = "Nat Service AZ1 ${var.stack_description}"
  }
}

resource "aws_nat_gateway" "az2_private_nat_service" {
  allocation_id = aws_eip.az2_nat_eip.id
  subnet_id     = aws_subnet.az2_public.id

  tags = {
    Name = "Nat Service AZ2 ${var.stack_description}"
  }
}
