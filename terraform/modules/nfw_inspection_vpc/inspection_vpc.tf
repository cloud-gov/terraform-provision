locals {
  # One entry per (AZ, internal CIDR) pair.
  internal_routes = merge([
    for az in var.availability_zones : {
      for cidr in var.internal_cidrs :
      "${az}:${cidr}" => { az = az, cidr = cidr }
    }
  ]...)

  # Map subnet CIDRs to a specific AZ for consistency.
  azs = {
    for idx, az in var.availability_zones : az => {
      firewall_cidr = var.firewall_subnet_cidrs[idx]
      tgw_cidr      = var.tgw_subnet_cidrs[idx]
      public_cidr   = var.public_subnet_cidrs[idx]
    }
  }
}

resource "aws_vpc" "inspection" {
  cidr_block           = var.inspection_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name_prefix}-vpc" })
}

# Subnets
resource "aws_subnet" "firewall" {
  for_each          = local.azs
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = each.value.firewall_cidr
  availability_zone = each.key
  tags              = merge(var.tags, { Name = "${var.name_prefix}-firewall-${each.key}" })
}

resource "aws_subnet" "tgw" {
  for_each          = local.azs
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = each.value.tgw_cidr
  availability_zone = each.key
  tags              = merge(var.tags, { Name = "${var.name_prefix}-tgw-${each.key}" })
}

resource "aws_subnet" "public" {
  for_each                = local.azs
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = each.value.public_cidr
  availability_zone       = each.key
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-public-${each.key}" })
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# nat gateways
resource "aws_eip" "ngw" {
  for_each = local.azs
  domain   = "vpc"
  tags     = merge(var.tags, { Name = "${var.name_prefix}-nat-eip-${each.key}" })
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_nat_gateway" "ngw" {
  for_each      = local.azs
  allocation_id = aws_eip.ngw[each.key].id
  subnet_id     = aws_subnet.public[each.key].id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-${each.key}" })
  depends_on    = [aws_internet_gateway.igw]
}

# Firewall Route Table
resource "aws_route_table" "firewall" {
  for_each = local.azs
  vpc_id   = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-firewall-rt-${each.key}" })
}

# Egress firewall > ngw
resource "aws_route" "firewall_egress" {
  for_each               = local.azs
  route_table_id         = aws_route_table.firewall[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[each.key].id
}

resource "aws_route" "firewall_internal" {
  for_each               = local.internal_routes
  route_table_id         = aws_route_table.firewall[each.value.az].id
  destination_cidr_block = each.value.cidr
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  depends_on             = [aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment]
}

resource "aws_route_table_association" "firewall" {
  for_each       = local.azs
  subnet_id      = aws_subnet.firewall[each.key].id
  route_table_id = aws_route_table.firewall[each.key].id
}

# TGW Route Table
resource "aws_route_table" "tgw" {
  for_each = local.azs
  vpc_id   = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-tgw-rt-${each.key}" })
}

# Egress TGW > Firewall
resource "aws_route" "tgw_egress" {
  for_each               = local.azs
  route_table_id         = aws_route_table.tgw[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.fw_endpoints[each.key]

  depends_on = [aws_networkfirewall_firewall.firewall]
}

resource "aws_route_table_association" "tgw" {
  for_each       = local.azs
  subnet_id      = aws_subnet.tgw[each.key].id
  route_table_id = aws_route_table.tgw[each.key].id
}

# Public Subnet Route Table
resource "aws_route_table" "public" {
  for_each = local.azs
  vpc_id   = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt-${each.key}" })
}

# Egress public subnet > IGW
resource "aws_route" "public_egress" {
  for_each               = local.azs
  route_table_id         = aws_route_table.public[each.key].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_ingress" {
  for_each = local.internal_routes

  route_table_id         = aws_route_table.public[each.value.az].id
  destination_cidr_block = each.value.cidr
  vpc_endpoint_id        = local.fw_endpoints[each.value.az]

  depends_on = [aws_networkfirewall_firewall.firewall]
}

resource "aws_route_table_association" "public" {
  for_each       = local.azs
  subnet_id      = aws_subnet.public[each.key].id
  route_table_id = aws_route_table.public[each.key].id
}
