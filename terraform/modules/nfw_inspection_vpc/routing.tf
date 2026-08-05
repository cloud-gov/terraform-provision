# TGW subnet route tables
# Traffic arriving from spokes goes to the firewall endpoint in the same AZ.
resource "aws_route_table" "tgw" {
  count  = 2
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-tgw-${var.availability_zones[count.index]}" })
}

resource "aws_route_table_association" "tgw" {
  count          = 2
  subnet_id      = aws_subnet.tgw[count.index].id
  route_table_id = aws_route_table.tgw[count.index].id
}

# From the TGW subnet, send ALL traffic (egress + east-west) to the firewall endpoint in the same AZ.
resource "aws_route" "tgw_to_fw" {
  count                  = 2
  route_table_id         = aws_route_table.tgw[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[count.index]]
}


# Firewall subnet route tables
# Post inspection: egress -> NAT; return-to-spoke -> TGW.
resource "aws_route_table" "firewall" {
  count  = 2
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-fw-${var.availability_zones[count.index]}" })
}

resource "aws_route_table_association" "firewall" {
  count          = 2
  subnet_id      = aws_subnet.firewall[count.index].id
  route_table_id = aws_route_table.firewall[count.index].id
}

# Egress default route -> NAT gateway in same AZ.
resource "aws_route" "fw_to_nat" {
  count                  = 2
  route_table_id         = aws_route_table.firewall[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this[count.index].id
}

# TODO: Get ingress & egress working first
# Return / east-west traffic to spoke CIDRs -> TGW.
# resource "aws_route" "fw_to_tgw" {
#   for_each = {
#     for pair in setproduct(range(2), local.all_spoke_cidrs) :
#     "${pair[0]}-${pair[1]}" => {
#       idx  = pair[0]
#       cidr = pair[1]
#     }
#   }

#   route_table_id         = aws_route_table.firewall[each.value.idx].id
#   destination_cidr_block = each.value.cidr
#   transit_gateway_id     = local.tgw_id

#   depends_on = [aws_ec2_transit_gateway_vpc_attachment.inspection]
# }


# Public/NAT subnet route tables
# Egress out to IGW; ingress return traffic to spokes must go back through the firewall.
resource "aws_route_table" "public" {
  count  = 2
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-public-${var.availability_zones[count.index]}" })
}

resource "aws_route_table_association" "public" {
  count          = 2
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public[count.index].id
}

# Default egress -> IGW.
resource "aws_route" "public_to_igw" {
  count                  = 2
  route_table_id         = aws_route_table.public[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.inspection.id
}

# Ingress: reply/return traffic destined to spoke CIDRs from the NAT subnet
# must be forced back through the firewall endpoint (in same AZ) before reaching TGW.
# resource "aws_route" "public_to_fw" {
#   for_each = {
#     for pair in setproduct(range(2), local.all_spoke_cidrs) :
#     "${pair[0]}-${pair[1]}" => {
#       idx  = pair[0]
#       cidr = pair[1]
#     }
#   }

#   route_table_id         = aws_route_table.public[each.value.idx].id
#   destination_cidr_block = each.value.cidr
#   vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[each.value.idx]]
# }


# IGW edge route table (INGRESS INSPECTION)
# Traffic arriving from the internet destined for spoke CIDRs is forced
# through the firewall endpoint before proceeding.
resource "aws_route_table" "igw_edge" {
  vpc_id = aws_vpc.inspection.id
  tags   = merge(var.tags, { Name = "${var.name_prefix}-rt-igw-edge" })
}

# Associate the route table with the IGW (edge association).
resource "aws_route_table_association" "igw_edge" {
  gateway_id     = aws_internet_gateway.inspection.id
  route_table_id = aws_route_table.igw_edge.id
}

# For each public subnet CIDR, send inbound traffic to the firewall endpoint in that AZ.
# This keeps ingress flows symmetric per AZ.
resource "aws_route" "igw_edge_to_fw" {
  count                  = 2
  route_table_id         = aws_route_table.igw_edge.id
  destination_cidr_block = var.public_subnet_cidrs[count.index]
  vpc_endpoint_id        = local.fw_endpoints[var.availability_zones[count.index]]
}
