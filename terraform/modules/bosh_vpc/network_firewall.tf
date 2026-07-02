# network_firewall.tf
#
# Optionally creates an AWS Network Firewall for centralized ingress/egress
# inspection (IPv4 and IPv6) of the public and private networks. Disabled by
# default.
#
# Topology (distributed model, dedicated firewall + NAT subnets per AZ):
#   Egress:  workload subnet -> firewall endpoint -> NAT subnet -> IGW
#   Ingress: IGW edge        -> firewall endpoint -> public subnet
#   NAT subnets route straight to IGW (never back through the firewall) to
#   avoid a routing loop; firewall endpoints never sit in their own workload
#   subnet, satisfying the "cannot inspect own subnet" constraint.
#
# Sources:
#   - AWS Network Firewall Developer Guide (architecture, dedicated firewall subnet)
#   - AWS blog: "Deployment models for AWS Network Firewall" (distributed model,
#     AZ-symmetric routing, inspect-then-NAT ordering)
#
# Variables required:
#   stack_description, az1, az2
#   create_network_firewall
#   firewall_cidr_1, firewall_cidr_2, nat_cidr_1, nat_cidr_2
#   firewall_managed_rule_groups, firewall_rule_groups_count_only

locals {
  fw_count = var.create_network_firewall ? 1 : 0

  firewall_managed_rule_groups = [
    for rg in var.firewall_managed_rule_groups : {
      resource_arn = rg.resource_arn
      priority     = rg.priority
      count_only   = var.firewall_rule_groups_count_only || rg.override_action_to_count
    }
  ]

  # AZ -> firewall endpoint id, derived from firewall sync_states.
  firewall_endpoints = var.create_network_firewall ? {
    for ss in tolist(aws_networkfirewall_firewall.main[0].firewall_status[0].sync_states) :
    ss.availability_zone => ss.attachment[0].endpoint_id
  } : {}

  # IPv6 CIDRs of the public subnets, for IGW ingress inspection routing.
  public_ipv6_cidr_az1 = aws_subnet.az1_public.ipv6_cidr_block
  public_ipv6_cidr_az2 = aws_subnet.az2_public.ipv6_cidr_block
}


# Firewall needs to live in its own subnets
resource "aws_subnet" "az1_firewall" {
  count             = local.fw_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.firewall_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (Firewall AZ1)"
  }
}

resource "aws_subnet" "az2_firewall" {
  count             = local.fw_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.firewall_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (Firewall AZ2)"
  }
}


# NAT gateways need to move to prevent circular routing through the firewall.
# They need their own route table, hence a separate subnet.
resource "aws_subnet" "az1_nat" {
  count             = local.fw_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.nat_cidr_1
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (NAT AZ1)"
  }
}

resource "aws_subnet" "az2_nat" {
  count             = local.fw_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.nat_cidr_2
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (NAT AZ2)"
  }
}

resource "aws_route_table" "az1_nat_route_table" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (NAT Route Table AZ1)"
  }
}

resource "aws_route_table" "az2_nat_route_table" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (NAT Route Table AZ2)"
  }
}

# Egress NAT > IGW
resource "aws_route" "az1_nat_default_igw" {
  count                  = local.fw_count
  route_table_id         = aws_route_table.az1_nat_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route" "az2_nat_default_igw" {
  count                  = local.fw_count
  route_table_id         = aws_route_table.az2_nat_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "az1_nat_rta" {
  count          = local.fw_count
  subnet_id      = aws_subnet.az1_nat[0].id
  route_table_id = aws_route_table.az1_nat_route_table[0].id
}

resource "aws_route_table_association" "az2_nat_rta" {
  count          = local.fw_count
  subnet_id      = aws_subnet.az2_nat[0].id
  route_table_id = aws_route_table.az2_nat_route_table[0].id
}

resource "aws_networkfirewall_firewall_policy" "main" {
  count = local.fw_count
  name  = "${replace(var.stack_description, " ", "-")}-firewall-policy"

  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    dynamic "stateful_rule_group_reference" {
      for_each = local.firewall_managed_rule_groups
      content {
        resource_arn = stateful_rule_group_reference.value.resource_arn
        priority     = stateful_rule_group_reference.value.priority

        dynamic "override" {
          for_each = stateful_rule_group_reference.value.count_only ? [1] : []
          content {
            action = "DROP_TO_ALERT" # Alert only
          }
        }
      }
    }
  }

  tags = {
    Name = "${var.stack_description} (Firewall Policy)"
  }
}

resource "aws_networkfirewall_firewall" "main" {
  count               = local.fw_count
  name                = "${var.stack_description}-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.main[0].arn
  vpc_id              = aws_vpc.main_vpc.id

  subnet_mapping {
    subnet_id = aws_subnet.az1_firewall[0].id
  }

  subnet_mapping {
    subnet_id = aws_subnet.az2_firewall[0].id
  }

  tags = {
    Name = "${var.stack_description} (Network Firewall)"
  }
}

#######################################
# Firewall subnet route tables
#   Post-inspection egress hops to the AZ's NAT gateway (IPv4).
#   IPv6 egress from firewall subnet goes directly to IGW.
#######################################

resource "aws_route_table" "az1_firewall_route_table" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Firewall Route Table AZ1)"
  }
}

resource "aws_route_table" "az2_firewall_route_table" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Firewall Route Table AZ2)"
  }
}

resource "aws_route" "az1_firewall_default_nat" {
  count                  = local.fw_count
  route_table_id         = aws_route_table.az1_firewall_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az1_private_nat_service.id
}

resource "aws_route" "az2_firewall_default_nat" {
  count                  = local.fw_count
  route_table_id         = aws_route_table.az2_firewall_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.az2_private_nat_service.id
}

# IPv6 egress from firewall subnet -> IGW (NAT gateways do not handle IPv6;
# IPv6 uses the egress-only IGW / IGW path, inspected upstream at the
# workload route tables).
resource "aws_route" "az1_firewall_ipv6_igw" {
  count                       = local.fw_count
  route_table_id              = aws_route_table.az1_firewall_route_table[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.gw.id
}

resource "aws_route" "az2_firewall_ipv6_igw" {
  count                       = local.fw_count
  route_table_id              = aws_route_table.az2_firewall_route_table[0].id
  destination_ipv6_cidr_block = "::/0"
  gateway_id                  = aws_internet_gateway.gw.id
}

resource "aws_route_table_association" "az1_firewall_rta" {
  count          = local.fw_count
  subnet_id      = aws_subnet.az1_firewall[0].id
  route_table_id = aws_route_table.az1_firewall_route_table[0].id
}

resource "aws_route_table_association" "az2_firewall_rta" {
  count          = local.fw_count
  subnet_id      = aws_subnet.az2_firewall[0].id
  route_table_id = aws_route_table.az2_firewall_route_table[0].id
}

#######################################
# IGW edge route table (ingress inspection, IPv4 + IPv6)
#   Inbound traffic destined for the public subnets is routed to the per-AZ
#   firewall endpoint before reaching the workload subnets. Associated with
#   the IGW via gateway_id on the route table association (edge association).
#######################################

resource "aws_route_table" "firewall_igw_ingress" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  # IPv4 ingress -> per-AZ firewall endpoint
  route {
    cidr_block      = aws_subnet.az1_public.cidr_block
    vpc_endpoint_id = local.firewall_endpoints[var.az1]
  }

  route {
    cidr_block      = aws_subnet.az2_public.cidr_block
    vpc_endpoint_id = local.firewall_endpoints[var.az2]
  }

  # IPv6 ingress -> per-AZ firewall endpoint
  route {
    ipv6_cidr_block = local.public_ipv6_cidr_az1
    vpc_endpoint_id = local.firewall_endpoints[var.az1]
  }

  route {
    ipv6_cidr_block = local.public_ipv6_cidr_az2
    vpc_endpoint_id = local.firewall_endpoints[var.az2]
  }

  tags = {
    Name = "${var.stack_description} (Firewall IGW Ingress Route Table)"
  }
}

resource "aws_route_table_association" "firewall_igw_edge" {
  count          = local.fw_count
  gateway_id     = aws_internet_gateway.gw.id
  route_table_id = aws_route_table.firewall_igw_ingress[0].id
}

#######################################
# Per-AZ public route tables (firewall enabled only)
#   Public workload egress (IPv4 + IPv6) goes through the AZ firewall endpoint,
#   preserving AZ-symmetric inspection. IPv6 is now inspected (Caveat C fix).
#######################################

resource "aws_route_table" "az1_public_firewall_rt" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoints[var.az1]
  }

  route {
    ipv6_cidr_block = "::/0"
    vpc_endpoint_id = local.firewall_endpoints[var.az1]
  }

  tags = {
    Name = "${var.stack_description} (Public Route Table AZ1 - Firewall)"
  }
}

resource "aws_route_table" "az2_public_firewall_rt" {
  count  = local.fw_count
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block      = "0.0.0.0/0"
    vpc_endpoint_id = local.firewall_endpoints[var.az2]
  }

  route {
    ipv6_cidr_block = "::/0"
    vpc_endpoint_id = local.firewall_endpoints[var.az2]
  }

  tags = {
    Name = "${var.stack_description} (Public Route Table AZ2 - Firewall)"
  }
}
