resource "aws_vpc" "inspection" {
  cidr_block           = var.inspection_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name_prefix}-inspection-vpc" })
}

# Subnets
resource "aws_subnet" "firewall" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = var.firewall_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { Name = "${var.name_prefix}-firewall-${var.availability_zones[count.index]}" })
}

resource "aws_subnet" "tgw" {
  count             = length(var.availability_zones)
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = var.tgw_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { Name = "${var.name_prefix}-tgw-${var.availability_zones[count.index]}" })
}

resource "aws_subnet" "public" {
  count                   = length(var.availability_zones)
  vpc_id                  = aws_vpc.inspection.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false
  tags                    = merge(var.tags, { Name = "${var.name_prefix}-public-${var.availability_zones[count.index]}" })
}

# internet gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-igw" })
}

# nat gateways
resource "aws_eip" "ngw" {
  count  = length(var.availability_zones)
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-eip-${var.availability_zones[count.index]}" })
}

resource "aws_nat_gateway" "ngw" {
  count         = length(var.availability_zones)
  allocation_id = aws_eip.ngw[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-${var.availability_zones[count.index]}" })
  depends_on    = [aws_internet_gateway.igw]
}


# Firewall Route Table
resource "aws_route_table" "firewall" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-firewall-rt-${var.availability_zones[count.index]}" })
}

# Egress firewall > ngw
resource "aws_route" "firewall_egress" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw[count.index].id
}

resource "aws_route" "firewall_internal" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.firewall[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id

  depends_on = [aws_ec2_transit_gateway_vpc_attachment.tgw-inspection-vpc-attachment]
}

resource "aws_route_table_association" "firewall" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.firewall[count.index].id
  route_table_id = aws_route_table.firewall[count.index].id
}

# TGW Route Table
resource "aws_route_table" "tgw" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-tgw-rt-${var.availability_zones[count.index]}" })
}

# Egress TGW > Firewall
resource "aws_route" "tgw_egress" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[count.index]]

  depends_on = [aws_networkfirewall_firewall.firewall]
}

resource "aws_route_table_association" "tgw" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw[count.index].id
}

# Public Subnet Route Table
resource "aws_route_table" "public" {
  count  = length(var.availability_zones)
  vpc_id = aws_vpc.inspection.id

  tags = merge(var.tags, { Name = "${var.name_prefix}-public-rt-${var.availability_zones[count.index]}" })
}

# Egress public subnet > IGW
resource "aws_route" "public_egress" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "public_ingress" {
  count                  = length(var.availability_zones)
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "10.0.0.0/8"
  vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[count.index]]

  depends_on = [aws_networkfirewall_firewall.firewall]
}

resource "aws_route_table_association" "public" {
  count          = length(var.availability_zones)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}
