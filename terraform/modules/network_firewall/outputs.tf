output "vpc_id" {
  value = data.aws_vpc.vpc.id
}

output "region" {
  value = data.aws_vpc.vpc.region
}

output "availability_zones" {
  value = data.aws_availability_zone.azs.name
}

output "environment" {
  value = var.environment
}

output "firewall_name" {
  value = aws_networkfirewall_firewall.network-firewall.name
}

output "firewall_subnets" {
  value = aws_subnet.firewall-subnets.cidr_block
}

output "protected_subnets" {
  value = data.aws_subnet.protected-subnets.cidr_block
}

output "home_nets" {
  value = var.home_nets
}

output "rule_groups" {
  value = var.rule_groups
}

