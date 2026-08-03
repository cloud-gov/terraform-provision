resource "aws_vpc" "inspection" {
  cidr_block           = var.inspection_vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags                 = merge(var.tags, { Name = "${var.name_prefix}-inspection-vpc" })
}

resource "aws_internet_gateway" "inspection" {
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-inspection-igw" })
}

resource "aws_subnet" "firewall" {
  count             = 2
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = var.firewall_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { Name = "${var.name_prefix}-firewall-${var.availability_zones[count.index]}" })
}

resource "aws_subnet" "transit_gateway" {
  count             = 2
  vpc_id            = aws_vpc.inspection.id
  cidr_block        = var.tgw_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]
  tags              = merge(var.tags, { Name = "${var.name_prefix}-tgw-${var.availability_zones[count.index]}" })
}

resource "aws_ec2_transit_gateway_vpc_attachment" "inspection" {
  transit_gateway_id                              = local.tgw_id
  vpc_id                                          = aws_vpc.inspection.id
  subnet_ids                                      = aws_subnet.transit_gateway[*].id
  appliance_mode_support                          = "enable"
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags                                            = merge(var.tags, { Name = "${var.name_prefix}-inspection-attachment" })
}

resource "aws_ec2_transit_gateway_route_table_association" "inspection" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.inspection.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.inspection.id
}

# resource "aws_subnet" "public" {
#   count                   = 2
#   vpc_id                  = aws_vpc.inspection.id
#   cidr_block              = var.public_subnet_cidrs[count.index]
#   availability_zone       = var.availability_zones[count.index]
#   map_public_ip_on_launch = false
#   tags                    = merge(var.tags, { Name = "${var.name_prefix}-public-${var.availability_zones[count.index]}" })
# }

# NAT for egress to the internet
resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
  tags   = merge(var.tags, { Name = "${var.name_prefix}-nat-eip-${var.availability_zones[count.index]}" })
}

# resource "aws_nat_gateway" "this" {
#   count         = 2
#   allocation_id = aws_eip.nat[count.index].id
#   subnet_id     = aws_subnet.public[count.index].id
#   tags          = merge(var.tags, { Name = "${var.name_prefix}-nat-${var.availability_zones[count.index]}" })
#   depends_on    = [aws_internet_gateway.inspection]
# }
