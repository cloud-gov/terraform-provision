/*
 * Variables required:
 *  stack_description
 *  az1
 *  az2
 *  public_cidr_1
 *  public_cidr_2
 *
 * Resources required:
 *   aws_vpc referenced as 'main_vpc'
 */

resource "aws_subnet" "az1_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_1

  // Hack: Default to a valid ipv6 cidr to handle empty vpc cidr on initial plan
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.main_vpc.ipv6_cidr_block != "" ? aws_vpc.main_vpc.ipv6_cidr_block : "fd00::/8",
    8,
    0,
  )
  availability_zone = var.az1

  tags = {
    Name = "${var.stack_description} (Public AZ1)"
  }
}

resource "aws_subnet" "az2_public" {
  vpc_id     = aws_vpc.main_vpc.id
  cidr_block = var.public_cidr_2

  // Hack: Default to a valid ipv6 cidr to handle empty vpc cidr on initial plan
  ipv6_cidr_block = cidrsubnet(
    aws_vpc.main_vpc.ipv6_cidr_block != "" ? aws_vpc.main_vpc.ipv6_cidr_block : "fd00::/8",
    8,
    1,
  )
  availability_zone = var.az2

  tags = {
    Name = "${var.stack_description} (Public AZ2)"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.stack_description} (Gateway)"
  }
}

# Firewall
locals {
  firewall_public_count  = var.create_network_firewall_public ? 1 : 0
  inspect_public_egress  = var.create_network_firewall_public && var.enable_network_firewall_public_egress ? true : false
  inspect_public_ingress = var.create_network_firewall_public && var.enable_network_firewall_public_ingress ? true : false

  firewall_public_managed_rule_groups = [
    for rg in var.firewall_public_managed_rule_groups : {
      resource_arn = rg.resource_arn
      priority     = rg.priority
      count_only   = var.firewall_public_rule_groups_count_only || rg.override_action_to_count
    }
  ]

  # AZ -> firewall endpoint id, derived from firewall sync_states.
  firewall_public_endpoints = var.create_network_firewall_public ? {
    for ss in tolist(aws_networkfirewall_firewall.public[0].firewall_status[0].sync_states) :
    ss.availability_zone => ss.attachment[0].endpoint_id
  } : {}

  # IPv6 CIDRs of the public subnets, for IGW ingress inspection routing.
  # public_ipv6_cidr_az1 = aws_subnet.az1_public.ipv6_cidr_block
  # public_ipv6_cidr_az2 = aws_subnet.az2_public.ipv6_cidr_block
}

resource "aws_networkfirewall_firewall_policy" "public" {
  count = local.firewall_public_count
  name  = "${replace(var.stack_description, " ", "-")}-firewall-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]
    dynamic "stateful_rule_group_reference" {
      for_each = local.firewall_public_managed_rule_groups
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
    Name = "${var.stack_description} (Firewall Policy - Public Subnet)"
  }
}

# Firewall needs to live in its own subnets
resource "aws_subnet" "az1_firewall_public" {
  count             = local.firewall_public_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.firewall_public_cidr_1
  availability_zone = var.az1
  tags = {
    Name = "${var.stack_description} (Firewall AZ1 - Public Subnet)"
  }
}
resource "aws_subnet" "az2_firewall_public" {
  count             = local.firewall_public_count
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = var.firewall_public_cidr_2
  availability_zone = var.az2
  tags = {
    Name = "${var.stack_description} (Firewall AZ2 - Public Subnet)"
  }
}

resource "aws_networkfirewall_firewall" "public" {
  count               = local.firewall_public_count
  name                = "${var.stack_description}-public-subnet-firewall"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.public[0].arn
  vpc_id              = aws_vpc.main_vpc.id
  subnet_mapping {
    subnet_id = aws_subnet.az1_firewall_public[0].id
  }
  subnet_mapping {
    subnet_id = aws_subnet.az2_firewall_public[0].id
  }
  tags = {
    Name = "${var.stack_description} (Network Firewall - Public Subnet)"
  }
}

# Firewall Logging
resource "aws_cloudwatch_log_group" "firewall_public_flow" {
  count             = local.firewall_public_count
  name              = "/${var.stack_description}/network_firewall_public/flow"
  retention_in_days = 30

  tags = {
    Name = "${var.stack_description}-network-firewall-public-flow-logs"
  }
}

resource "aws_cloudwatch_log_group" "firewall_public_alert" {
  count             = local.firewall_public_count
  name              = "/${var.stack_description}/network_firewall_public/alert"
  retention_in_days = 30

  tags = {
    Name = "${var.stack_description}-network-firewall-public-alert-logs"
  }
}

resource "aws_networkfirewall_logging_configuration" "public" {
  count        = local.firewall_public_count
  firewall_arn = aws_networkfirewall_firewall.public.arn

  logging_configuration {
    log_destination_config {
      log_type             = "FLOW"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_public_flow.name
      }
    }

    log_destination_config {
      log_type             = "ALERT"
      log_destination_type = "CloudWatchLogs"
      log_destination = {
        logGroup = aws_cloudwatch_log_group.firewall_public_alert.name
      }
    }
  }
}

# Egress Routing
resource "aws_route_table" "public_network" {
  vpc_id = aws_vpc.main_vpc.id
  dynamic "route" {
    for_each = local.inspect_public_egress ? [] : [1]
    content {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
    }
  }
  dynamic "route" {
    for_each = local.inspect_public_egress ? [1] : []
    content {
      cidr_block      = "0.0.0.0/0"
      vpc_endpoint_id = local.firewall_public_endpoints[var.az1]
    }
  }
  dynamic "route" {
    for_each = local.inspect_public_egress ? [] : [1]
    content {
      ipv6_cidr_block = "::/0"
      gateway_id      = aws_internet_gateway.gw.id
    }
  }
  dynamic "route" {
    for_each = local.inspect_public_egress ? [1] : []
    content {
      ipv6_cidr_block = "::/0"
      vpc_endpoint_id = local.firewall_public_endpoints[var.az1]
    }
  }
  tags = {
    Name = "${var.stack_description} (Public Route Table)"
  }
}
resource "aws_route_table_association" "az1_public_rta" {
  subnet_id      = aws_subnet.az1_public.id
  route_table_id = aws_route_table.public_network.id
}
resource "aws_route_table_association" "az2_public_rta" {
  subnet_id      = aws_subnet.az2_public.id
  route_table_id = aws_route_table.public_network.id
}

resource "aws_route_table" "az1_firewall_public_egress" {
  count  = local.inspect_public_egress ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.stack_description} (Firewall Route Table AZ1 - Public Subnet)"
  }
}
resource "aws_route_table" "az2_firewall_public_egress" {
  count  = local.inspect_public_egress ? 1 : 0
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }
  route {
    ipv6_cidr_block = "::/0"
    gateway_id      = aws_internet_gateway.gw.id
  }
  tags = {
    Name = "${var.stack_description} (Firewall Route Table AZ2 - Public Subnet)"
  }
}
resource "aws_route_table_association" "az1_firewall_public" {
  count          = local.inspect_public_egress ? 1 : 0
  subnet_id      = aws_subnet.az1_firewall_public[0].id
  route_table_id = aws_route_table.az1_firewall_public_egress[0].id
}
resource "aws_route_table_association" "az2_firewall_public" {
  count          = local.inspect_public_egress ? 1 : 0
  subnet_id      = aws_subnet.az2_firewall_public[0].id
  route_table_id = aws_route_table.az2_firewall_public_egress[0].id
}


# Ingress Routing
# Note: The 'local' route is created automatically by AWS.
resource "aws_route_table" "public_ingress" {
  count  = local.inspect_public_ingress ? 1 : 0
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.stack_description} (Firewall Ingress - Public Subnet)"
  }
}
resource "aws_route_table_association" "ingress" {
  count          = local.inspect_public_ingress ? 1 : 0
  gateway_id     = aws_internet_gateway.gw.id
  route_table_id = aws_route_table.ingress.id
}
resource "aws_route" "ingress_to_public_1" {
  count                  = local.inspect_public_ingress ? 1 : 0
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.public_cidr_1
  vpc_endpoint_id        = local.firewall_public_endpoints[var.az1]
}
resource "aws_route" "ingress_to_public_2" {
  count                  = local.inspect_public_ingress ? 1 : 0
  route_table_id         = aws_route_table.ingress.id
  destination_cidr_block = var.public_cidr_2
  vpc_endpoint_id        = local.firewall_public_endpoints[var.az2]
}
