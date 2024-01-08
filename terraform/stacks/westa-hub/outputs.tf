# Declare values used in multiple outputs
locals { ##
  private_subnet_reserved = ["${cidrhost(module.stack.private_cidrs[0], 0)} - ${cidrhost(module.stack.private_cidrs[0], 3)}", "${cidrhost(module.stack.private_cidrs[1], 0)} - ${cidrhost(module.stack.private_cidrs[1], 3)}", "${cidrhost(module.stack.private_cidrs[2], 0)} - ${cidrhost(module.stack.private_cidrs[2], 3)}"]
  protobosh_static_ip     = cidrhost(module.stack.private_cidrs[0], 6)
  bosh_static_ip          = cidrhost(module.stack.private_cidrs[2], 6)
  bosh_uaa_static_ips = [
    cidrhost(module.stack.private_cidrs[0], 4),
    cidrhost(module.stack.private_cidrs[1], 4),
    cidrhost(module.stack.private_cidrs[2], 4),
  ]

  bosh_uaa_static_ips_az1 = [cidrhost(module.stack.private_cidrs[0], 4)]
  bosh_uaa_static_ips_az2 = [cidrhost(module.stack.private_cidrs[1], 4)]
  bosh_uaa_static_ips_az3 = [cidrhost(module.stack.private_cidrs[2], 4)]

  production_smtp_private_ip  = cidrhost(module.stack.private_cidrs[0], 12)
  private_subnet_reserved_az1 = ["${cidrhost(module.stack.private_cidrs[0], 0)} - ${cidrhost(module.stack.private_cidrs[0], 3)}"]
  private_subnet_reserved_az2 = ["${cidrhost(module.stack.private_cidrs[1], 0)} - ${cidrhost(module.stack.private_cidrs[1], 3)}"]
  private_subnet_reserved_az3 = ["${cidrhost(module.stack.private_cidrs[2], 0)} - ${cidrhost(module.stack.private_cidrs[2], 3)}"]
}

#staging_dns_private_ips = [
#  cidrhost(module.stack.private_cidr_az1, 8),
#  cidrhost(module.stack.private_cidr_az1, 9),
#]
#production_dns_private_ips = [
#  cidrhost(module.stack.private_cidr_az1, 10),
#  cidrhost(module.stack.private_cidr_az1, 11),
#]

output "availability_zone_names" {
  value = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1], data.aws_availability_zones.available.names[2]]
}

output "az1" {
  value = data.aws_availability_zones.available.names[0]
}

output "az2" {
  value = data.aws_availability_zones.available.names[1]
}

output "az3" {
  value = data.aws_availability_zones.available.names[2]
}

output "stack_description" {
  value = var.stack_description
}

/* VPC */
output "vpc_region" {
  value = var.aws_default_region
}

output "vpc_id" {
  value = module.stack.vpc_id
}

output "vpc_cidr" {
  value = module.stack.vpc_cidr
}

output "vpc_cidr_dns" {
  value = cidrhost(module.stack.vpc_cidr, 2)
}

/* Private network */
output "private_subnet_ids" {
  value = module.stack.private_subnet_ids
}

output "private_subnet_az1" {
  value = module.stack.private_subnet_ids[0]
}

output "private_subnet_az2" {
  value = module.stack.private_subnet_ids[1]
}

output "private_subnet_az3" {
  value = module.stack.private_subnet_ids[2]
}

output "private_router_table_ids" {
  value = module.stack.private_route_table_ids
}

output "private_subnet_cidrs" {
  value = module.stack.private_cidrs
}

output "private_subnet_az1_cidr" {
  value = module.stack.private_cidrs[0]
}

output "private_subnet_az2_cidr" {
  value = module.stack.private_cidrs[1]
}

output "private_subnet_az3_cidr" {
  value = module.stack.private_cidrs[2]
}

output "protobosh_reserved" { ##
  value = concat(
    local.private_subnet_reserved,
    [local.protobosh_static_ip],
    local.bosh_uaa_static_ips,
    [local.production_smtp_private_ip],
  )
}

output "protobosh_reserved_az1" { ##
  value = concat(
    local.private_subnet_reserved_az1,
    [local.protobosh_static_ip],
    local.bosh_uaa_static_ips_az1,
    [local.production_smtp_private_ip],
  )
}

output "protobosh_reserved_az2" { ##
  value = concat(
    local.private_subnet_reserved_az2,
    local.bosh_uaa_static_ips_az2,
  )
}

output "protobosh_reserved_az3" { ##
  value = concat(
    local.private_subnet_reserved_az3,
    local.bosh_uaa_static_ips_az3,
  )
}

#  local.staging_dns_private_ips,
#  local.production_dns_private_ips,

output "private_subnet_reserved" { ##
  value = local.private_subnet_reserved
}
output "private_subnet_reserved_az1" { ##
  value = local.private_subnet_reserved[0]
}
output "private_subnet_reserved_az2" { ##
  value = local.private_subnet_reserved[1]
}
output "private_subnet_reserved_az3" { ##
  value = local.private_subnet_reserved[2]
}

output "private_subnet_gateways" {
  value = [cidrhost(module.stack.private_cidrs[0], 1), cidrhost(module.stack.private_cidrs[1], 1), cidrhost(module.stack.private_cidrs[2], 1)]
}

output "private_subnet_az1_gateway" {
  value = cidrhost(module.stack.private_cidrs[0], 1)
}

output "private_subnet_az2_gateway" {
  value = cidrhost(module.stack.private_cidrs[1], 1)
}

output "private_subnet_az3_gateway" {
  value = cidrhost(module.stack.private_cidrs[2], 1)
}

output "production_monitoring_subnet_reserved" {
  value = ["${cidrhost(module.monitoring_production.monitoring_cidrs[0], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[0], 3)}", "${cidrhost(module.monitoring_production.monitoring_cidrs[1], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[1], 3)}", "${cidrhost(module.monitoring_production.monitoring_cidrs[2], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[2], 3)}"]
}
output "production_monitoring_subnet_reserved_az1" {
  value = "${cidrhost(module.monitoring_production.monitoring_cidrs[0], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[0], 3)}"
}
output "production_monitoring_subnet_reserved_az2" {
  value = "${cidrhost(module.monitoring_production.monitoring_cidrs[1], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[1], 3)}"
}
output "production_monitoring_subnet_reserved_az3" {
  value = "${cidrhost(module.monitoring_production.monitoring_cidrs[2], 0)} - ${cidrhost(module.monitoring_production.monitoring_cidrs[2], 3)}"
}

output "staging_monitoring_subnet_reserved" {
  value = ["${cidrhost(module.monitoring_staging.monitoring_cidrs[0], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[0], 3)}", "${cidrhost(module.monitoring_staging.monitoring_cidrs[1], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[1], 3)}", "${cidrhost(module.monitoring_staging.monitoring_cidrs[2], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[2], 3)}"]
}

output "staging_monitoring_subnet_reserved_az1" {
  value = "${cidrhost(module.monitoring_staging.monitoring_cidrs[0], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[0], 3)}"
}
output "staging_monitoring_subnet_reserved_az2" {
  value = "${cidrhost(module.monitoring_staging.monitoring_cidrs[1], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[1], 3)}"
}
output "staging_monitoring_subnet_reserved_az3" {
  value = "${cidrhost(module.monitoring_staging.monitoring_cidrs[2], 0)} - ${cidrhost(module.monitoring_staging.monitoring_cidrs[2], 3)}"
}



output "production_monitoring_subnet_cidrs" {
  value = module.monitoring_production.monitoring_cidrs
}
output "production_monitoring_subnet_cidr_az1" {
  value = module.monitoring_production.monitoring_cidrs[0]
}
output "production_monitoring_subnet_cidr_az2" {
  value = module.monitoring_production.monitoring_cidrs[1]
}
output "production_monitoring_subnet_cidr_az3" {
  value = module.monitoring_production.monitoring_cidrs[2]
}

output "staging_monitoring_subnet_cidrs" {
  value = module.monitoring_staging.monitoring_cidrs
}

output "staging_monitoring_subnet_cidr_az1" {
  value = module.monitoring_staging.monitoring_cidrs[0]
}
output "staging_monitoring_subnet_cidr_az2" {
  value = module.monitoring_staging.monitoring_cidrs[1]
}
output "staging_monitoring_subnet_cidr_az3" {
  value = module.monitoring_staging.monitoring_cidrs[2]
}

output "production_monitoring_subnet_gateways" {
  value = [cidrhost(module.monitoring_production.monitoring_cidrs[0], 1), cidrhost(module.monitoring_production.monitoring_cidrs[1], 1), cidrhost(module.monitoring_production.monitoring_cidrs[2], 1)]
}

output "production_monitoring_subnet_gateway_az1" {
  value = cidrhost(module.monitoring_production.monitoring_cidrs[0], 1)
}
output "production_monitoring_subnet_gateway_az2" {
  value = cidrhost(module.monitoring_production.monitoring_cidrs[1], 1)
}
output "production_monitoring_subnet_gateway_az3" {
  value = cidrhost(module.monitoring_production.monitoring_cidrs[2], 1)
}

output "staging_monitoring_subnet_gateways" {
  value = [cidrhost(module.monitoring_staging.monitoring_cidrs[0], 1), cidrhost(module.monitoring_staging.monitoring_cidrs[1], 1), cidrhost(module.monitoring_staging.monitoring_cidrs[2], 1)]
}
output "staging_monitoring_subnet_gateway_az1" {
  value = cidrhost(module.monitoring_staging.monitoring_cidrs[0], 1)
}

output "staging_monitoring_subnet_gateway_az2" {
  value = cidrhost(module.monitoring_staging.monitoring_cidrs[1], 1)
}

output "staging_monitoring_subnet_gateway_az3" {
  value = cidrhost(module.monitoring_staging.monitoring_cidrs[2], 1)
}


output "protobosh_static_ip" {
  value = local.protobosh_static_ip
}

output "master_bosh_static_ip" {
  value = local.protobosh_static_ip
}

output "tooling_bosh_static_ip" {
  value = local.bosh_static_ip
}

output "bosh_static_ip" {
  value = local.bosh_static_ip
}

output "bosh_uaa_static_ips" {
  value = local.bosh_uaa_static_ips
}
output "bosh_uaa_static_ips_az1" {
  value = local.bosh_uaa_static_ips[0]
}
output "bosh_uaa_static_ips_az2" {
  value = local.bosh_uaa_static_ips[1]
}
output "bosh_uaa_static_ips_az3" {
  value = local.bosh_uaa_static_ips[2]
}



output "bosh_network_static_ips" {
  value = concat([local.bosh_static_ip], local.bosh_uaa_static_ips)
}

/* Public network */
output "public_subnet_ids" {
  value = module.stack.public_subnet_ids
}
output "public_subnet_az1" {
  value = module.stack.public_subnet_ids[0]
}
output "public_subnet_az2" {
  value = module.stack.public_subnet_ids[1]
}
output "public_subnet_az3" {
  value = module.stack.public_subnet_ids[2]
}

output "public_subnet_cidrs" {
  value = module.stack.public_cidrs
}

output "public_route_table_ids" {
  value = module.stack.public_route_table_ids
}

output "nat_egress_ips" {
  value = module.stack.nat_egress_ips
}

/* Security Groups */
output "bosh_security_group" {
  value = module.stack.bosh_security_group
}

output "local_vpc_traffic_security_group" {
  value = module.stack.local_vpc_traffic_security_group
}

output "web_traffic_security_group" {
  value = module.stack.web_traffic_security_group
}

output "nessus_security_group" {
  value = aws_security_group.nessus_traffic.id
}

output "bosh_uaa_security_group" {
  value = aws_security_group.bosh_uaa_traffic.id
}

/* RDS Network */
output "rds_subnet_ids" {
  value = module.stack.rds_subnet_ids
}

output "rds_subnet_group" {
  value = module.stack.rds_subnet_group
}

output "rds_mysql_security_group" {
  value = module.stack.rds_mysql_security_group
}

output "rds_postgres_security_group" {
  value = module.stack.rds_postgres_security_group
}

output "rds_mssql_security_group" {
  value = module.stack.rds_mssql_security_group
}

output "rds_oracle_security_group" {
  value = module.stack.rds_oracle_security_group
}

/* RDS Bosh Instance */
output "bosh_rds_url_curr" {
  value = module.stack.bosh_rds_url_curr
}

output "bosh_rds_host_curr" {
  value = module.stack.bosh_rds_host_curr
}


# Should delete this one off the face of the earth with extreme prejudice... TODO
output "bosh_rds_url_prev" {
  value = module.stack.bosh_rds_url_prev
}

output "bosh_rds_host_prev" {
  value = module.stack.bosh_rds_host_prev
}

output "bosh_rds_port" {
  value = module.stack.bosh_rds_port
}

output "bosh_rds_username" {
  value = module.stack.bosh_rds_username
}

output "bosh_rds_password" {
  value     = module.stack.bosh_rds_password
  sensitive = true
}

/* CredHub RDS */
output "protobosh_rds_url" {
  value = module.stack.protobosh_rds_url
}

output "protobosh_rds_host" {
  value = module.stack.protobosh_rds_host
}

output "protobosh_rds_port" {
  value = module.stack.protobosh_rds_port
}

output "protobosh_rds_username" {
  value = module.stack.protobosh_rds_username
}

output "protobosh_rds_password" {
  value     = module.stack.protobosh_rds_password
  sensitive = true
}

/* Main LB */
output "main_lb_name" {
  value = aws_lb.main.name
}

output "main_lb_dns_name" {
  value = aws_lb.main.dns_name
}

/* Production Concourse */
output "production_concourse_subnet_ids" {
  value = module.concourse_production.concourse_subnet_ids
}
output "production_concourse_subnet_az1" {
  value = module.concourse_production.concourse_subnet_ids[0]
}
output "production_concourse_subnet_az2" {
  value = module.concourse_production.concourse_subnet_ids[1]
}
output "production_concourse_subnet_az3" {
  value = module.concourse_production.concourse_subnet_ids[2]
}


output "production_concourse_subnet_reserved" {
  value = ["${cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 3)}", "${cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 3)}", "${cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 3)}"]
}

output "production_concourse_subnet_reserved_az1" {
  value = "${cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 3)}"
}
output "production_concourse_subnet_reserved_az2" {
  value = "${cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 3)}"
}
output "production_concourse_subnet_reserved_az3" {
  value = "${cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 0)} - ${cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 3)}"
}




output "production_concourse_subnet_cidrs" {
  value = module.concourse_production.concourse_subnet_cidrs
}

output "production_concourse_subnet_cidr_az1" {
  value = module.concourse_production.concourse_subnet_cidrs[0]
}
output "production_concourse_subnet_cidr_az2" {
  value = module.concourse_production.concourse_subnet_cidrs[1]
}
output "production_concourse_subnet_cidr_az3" {
  value = module.concourse_production.concourse_subnet_cidrs[2]
}


output "production_concourse_subnet_gateways" {
  value = [cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 1), cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 1), cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 1)]
}
output "production_concourse_subnet_gateway_az1" {
  value = cidrhost(module.concourse_production.concourse_subnet_cidrs[0], 1)
}
output "production_concourse_subnet_gateway_az2" {
  value = cidrhost(module.concourse_production.concourse_subnet_cidrs[1], 1)
}
output "production_concourse_subnet_gateway_az3" {
  value = cidrhost(module.concourse_production.concourse_subnet_cidrs[2], 1)
}

output "production_concourse_security_group" {
  value = module.concourse_production.concourse_security_group
}

output "production_concourse_rds_identifier" {
  value = module.concourse_production.concourse_rds_identifier
}

output "production_concourse_rds_name" {
  value = module.concourse_production.concourse_rds_name
}

output "production_concourse_rds_host" {
  value = module.concourse_production.concourse_rds_host
}

output "production_concourse_rds_port" {
  value = module.concourse_production.concourse_rds_port
}

output "production_concourse_rds_url" {
  value = module.concourse_production.concourse_rds_url
}

output "production_concourse_rds_username" {
  value = module.concourse_production.concourse_rds_username
}

output "production_concourse_rds_password" {
  value     = module.concourse_production.concourse_rds_password
  sensitive = true
}

output "production_concourse_lb_target_group" {
  value = module.concourse_production.concourse_lb_target_group
}

/* Staging Concourse */
output "staging_concourse_subnet_ids" {
  value = module.concourse_staging.concourse_subnet_ids
}
output "staging_concourse_subnet_az1" {
  value = module.concourse_staging.concourse_subnet_ids[0]
}
output "staging_concourse_subnet_az2" {
  value = module.concourse_staging.concourse_subnet_ids[1]
}
output "staging_concourse_subnet_az3" {
  value = module.concourse_staging.concourse_subnet_ids[2]
}
output "staging_concourse_subnet_reserved" {
  value = ["${cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 3)}", "${cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 3)}", "${cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 3)}"]
}
output "staging_concourse_subnet_reserved_az1" {
  value = "${cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 3)}"
}

output "staging_concourse_subnet_reserved_az2" {
  value = "${cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 3)}"
}

output "staging_concourse_subnet_reserved_az3" {
  value = "${cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 0)} - ${cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 3)}"
}

output "staging_concourse_subnet_cidrs" {
  value = module.concourse_staging.concourse_subnet_cidrs
}

output "staging_concourse_subnet_cidr_az1" {
  value = module.concourse_staging.concourse_subnet_cidrs[0]
}
output "staging_concourse_subnet_cidr_az2" {
  value = module.concourse_staging.concourse_subnet_cidrs[1]
}
output "staging_concourse_subnet_cidr_az3" {
  value = module.concourse_staging.concourse_subnet_cidrs[2]
}

output "staging_concourse_subnet_gateways" {
  value = [cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 1), cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 1), cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 1)]
}
output "staging_concourse_subnet_gateway_az1" {
  value = cidrhost(module.concourse_staging.concourse_subnet_cidrs[0], 1)
}
output "staging_concourse_subnet_gateway_az2" {
  value = cidrhost(module.concourse_staging.concourse_subnet_cidrs[1], 1)
}
output "staging_concourse_subnet_gateway_az3" {
  value = cidrhost(module.concourse_staging.concourse_subnet_cidrs[2], 1)
}

output "staging_concourse_security_group" {
  value = module.concourse_staging.concourse_security_group
}

output "staging_concourse_rds_identifier" {
  value = module.concourse_staging.concourse_rds_identifier
}

output "staging_concourse_rds_name" {
  value = module.concourse_staging.concourse_rds_name
}

output "staging_concourse_rds_host" {
  value = module.concourse_staging.concourse_rds_host
}

output "staging_concourse_rds_port" {
  value = module.concourse_staging.concourse_rds_port
}

output "staging_concourse_rds_url" {
  value = module.concourse_staging.concourse_rds_url
}

output "staging_concourse_rds_username" {
  value = module.concourse_staging.concourse_rds_username
}

output "staging_concourse_rds_password" {
  value     = module.concourse_staging.concourse_rds_password
  sensitive = true
}

output "staging_concourse_lb_target_group" {
  value = module.concourse_staging.concourse_lb_target_group
}

/* Production credhub */
output "production_credhub_subnet_ids" {
  value = module.credhub_production.credhub_subnet_ids
}
output "production_credhub_subnet_az1" {
  value = module.credhub_production.credhub_subnet_ids[0]
}
output "production_credhub_subnet_az2" {
  value = module.credhub_production.credhub_subnet_ids[1]
}
output "production_credhub_subnet_az3" {
  value = module.credhub_production.credhub_subnet_ids[2]
}

output "production_credhub_subnet_reserved" {
  value = ["${cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 3)}", "${cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 3)}", "${cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 3)}"]
}
output "production_credhub_subnet_reserved_az1" {
  value = "${cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 3)}"
}
output "production_credhub_subnet_reserved_az2" {
  value = "${cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 3)}"
}
output "production_credhub_subnet_reserved_az3" {
  value = "${cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 0)} - ${cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 3)}"
}

output "production_credhub_subnet_cidrs" {
  value = module.credhub_production.credhub_subnet_cidrs
}
output "production_credhub_subnet_cidr_az1" {
  value = module.credhub_production.credhub_subnet_cidrs[0]
}
output "production_credhub_subnet_cidr_az2" {
  value = module.credhub_production.credhub_subnet_cidrs[1]
}
output "production_credhub_subnet_cidr_az3" {
  value = module.credhub_production.credhub_subnet_cidrs[2]
}

output "production_credhub_subnet_gateways" {
  value = [cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 1), cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 1), cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 1)]
}
output "production_credhub_subnet_gateway_az1" {
  value = cidrhost(module.credhub_production.credhub_subnet_cidrs[0], 1)
}
output "production_credhub_subnet_gateway_az2" {
  value = cidrhost(module.credhub_production.credhub_subnet_cidrs[1], 1)
}
output "production_credhub_subnet_gateway_az3" {
  value = cidrhost(module.credhub_production.credhub_subnet_cidrs[2], 1)
}

output "production_credhub_security_group" {
  value = module.credhub_production.credhub_security_group
}

output "production_credhub_rds_identifier" {
  value = module.credhub_production.credhub_rds_identifier
}

output "production_credhub_rds_name" {
  value = module.credhub_production.credhub_rds_name
}

output "production_credhub_rds_host" {
  value = module.credhub_production.credhub_rds_host
}

output "production_credhub_rds_port" {
  value = module.credhub_production.credhub_rds_port
}

output "production_credhub_rds_url" {
  value = module.credhub_production.credhub_rds_url
}

output "production_credhub_rds_username" {
  value = module.credhub_production.credhub_rds_username
}

output "production_credhub_rds_password" {
  value     = module.credhub_production.credhub_rds_password
  sensitive = true
}

output "production_credhub_lb_target_group" {
  value = module.credhub_production.credhub_lb_target_group
}

/* Staging credhub */
output "staging_credhub_subnet_ids" {
  value = module.credhub_staging.credhub_subnet_ids
}
output "staging_credhub_subnet_az1" {
  value = module.credhub_staging.credhub_subnet_ids[0]
}
output "staging_credhub_subnet_az2" {
  value = module.credhub_staging.credhub_subnet_ids[1]
}
output "staging_credhub_subnet_az3" {
  value = module.credhub_staging.credhub_subnet_ids[2]
}

output "staging_credhub_subnet_reserved" {
  value = ["${cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 3)}", "${cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 3)}", "${cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 3)}"]
}
output "staging_credhub_subnet_reserved_az1" {
  value = "${cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 3)}"
}
output "staging_credhub_subnet_reserved_az2" {
  value = "${cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 3)}"
}
output "staging_credhub_subnet_reserved_az3" {
  value = "${cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 0)} - ${cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 3)}"
}

output "staging_credhub_subnet_cidrs" {
  value = module.credhub_staging.credhub_subnet_cidrs
}
output "staging_credhub_subnet_cidr_az1" {
  value = module.credhub_staging.credhub_subnet_cidrs[0]
}
output "staging_credhub_subnet_cidr_az2" {
  value = module.credhub_staging.credhub_subnet_cidrs[1]
}
output "staging_credhub_subnet_cidr_az3" {
  value = module.credhub_staging.credhub_subnet_cidrs[2]
}

output "staging_credhub_subnet_gateways" {
  value = [cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 1), cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 1), cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 1)]
}
output "staging_credhub_subnet_gateway_az1" {
  value = cidrhost(module.credhub_staging.credhub_subnet_cidrs[0], 1)
}
output "staging_credhub_subnet_gateway_az2" {
  value = cidrhost(module.credhub_staging.credhub_subnet_cidrs[1], 1)
}
output "staging_credhub_subnet_gateway_az3" {
  value = cidrhost(module.credhub_staging.credhub_subnet_cidrs[2], 1)
}

output "staging_credhub_security_group" {
  value = module.credhub_staging.credhub_security_group
}

output "staging_credhub_rds_identifier" {
  value = module.credhub_staging.credhub_rds_identifier
}

output "staging_credhub_rds_name" {
  value = module.credhub_staging.credhub_rds_name
}

output "staging_credhub_rds_host" {
  value = module.credhub_staging.credhub_rds_host
}

output "staging_credhub_rds_port" {
  value = module.credhub_staging.credhub_rds_port
}

output "staging_credhub_rds_url" {
  value = module.credhub_staging.credhub_rds_url
}

output "staging_credhub_rds_username" {
  value = module.credhub_staging.credhub_rds_username
}

output "staging_credhub_rds_password" {
  value     = module.credhub_staging.credhub_rds_password
  sensitive = true
}

output "staging_credhub_lb_target_group" {
  value = module.credhub_staging.credhub_lb_target_group
}

/* Staging Defect Dojo */
#output "staging_defectdojo_subnet_az1" {
#  value = module.defectdojo_staging.defectdojo_subnet_az1
#}
#
#output "staging_defectdojo_subnet_az2" {
#  value = module.defectdojo_staging.defectdojo_subnet_az2
#}
#
#output "staging_defectdojo_subnet_az1_reserved" {
#  value = "${cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az1, 0)} - ${cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az1, 3)}"
#}
#
#output "staging_defectdojo_subnet_az2_reserved" {
#  value = "${cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az2, 0)} - ${cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az2, 3)}"
#}
#
#output "staging_defectdojo_subnet_cidr_az1" {
#  value = module.defectdojo_staging.defectdojo_subnet_cidr_az1
#}
#
#output "staging_defectdojo_subnet_cidr_az2" {
#  value = module.defectdojo_staging.defectdojo_subnet_cidr_az2
#}
#
#output "staging_defectdojo_subnet_az1_gateway" {
#  value = cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az1, 1)
#}
#
#output "staging_defectdojo_subnet_az2_gateway" {
#  value = cidrhost(module.defectdojo_staging.defectdojo_subnet_cidr_az2, 1)
#}
#
#output "staging_defectdojo_security_group" {
#  value = module.defectdojo_staging.defectdojo_security_group
#}
#
#output "staging_defectdojo_rds_identifier" {
#  value = module.defectdojo_staging.defectdojo_rds_identifier
#}
#
#output "staging_defectdojo_rds_name" {
#  value = module.defectdojo_staging.defectdojo_rds_name
#}
#
#output "staging_defectdojo_rds_host" {
#  value = module.defectdojo_staging.defectdojo_rds_host
#}
#
#output "staging_defectdojo_rds_port" {
#  value = module.defectdojo_staging.defectdojo_rds_port
#}
#
#output "staging_defectdojo_rds_url" {
#  value = module.defectdojo_staging.defectdojo_rds_url
#}
#
#output "staging_defectdojo_rds_username" {
#  value = module.defectdojo_staging.defectdojo_rds_username
#}
#
#output "staging_defectdojo_rds_password" {
#  value     = module.defectdojo_staging.defectdojo_rds_password
#  sensitive = true
#}
#
#output "staging_defectdojo_lb_target_group" {
#  value = module.defectdojo_staging.defectdojo_lb_target_group
#}

/* Production Monitoring */
output "production_monitoring_az" { ## might not be needed
  value = module.monitoring_production.monitoring_availability_zones
}

output "production_monitoring_subnet_ids" {
  value = module.monitoring_production.monitoring_subnet_ids
}
output "production_monitoring_subnet_az1" {
  value = module.monitoring_production.monitoring_subnet_ids[0]
}
output "production_monitoring_subnet_az2" {
  value = module.monitoring_production.monitoring_subnet_ids[1]
}
output "production_monitoring_subnet_az3" {
  value = module.monitoring_production.monitoring_subnet_ids[2]
}

output "production_monitoring_security_group" {
  value = module.monitoring_production.monitoring_security_group
}

output "production_monitoring_lb_target_group" {
  value = module.monitoring_production.lb_target_group
}

output "production_doomsday_lb_target_group" {
  value = module.monitoring_production.doomsday_lb_target_group
}

output "monitoring_security_groups" {
  value = {
    staging     = module.monitoring_staging.monitoring_security_group
    development = module.monitoring_staging.monitoring_security_group
    production  = module.monitoring_production.monitoring_security_group
  }
}

/* Staging Monitoring */
output "staging_monitoring_az" { ## might not be needed
  value = module.monitoring_staging.monitoring_availability_zones
}

output "staging_monitoring_subnet_ids" {
  value = module.monitoring_staging.monitoring_subnet_ids
}
output "staging_monitoring_subnet_az1" {
  value = module.monitoring_staging.monitoring_subnet_ids[0]
}
output "staging_monitoring_subnet_az2" {
  value = module.monitoring_staging.monitoring_subnet_ids[1]
}
output "staging_monitoring_subnet_az3" {
  value = module.monitoring_staging.monitoring_subnet_ids[2]
}

output "staging_monitoring_security_group" {
  value = module.monitoring_staging.monitoring_security_group
}

output "staging_monitoring_lb_target_group" {
  value = module.monitoring_staging.lb_target_group
}

output "staging_doomsday_lb_target_group" {
  value = module.monitoring_staging.doomsday_lb_target_group
}


/* rds storage user */
output "rds_storage_alert_username" {
  value = module.rds_storage_alert.username
}

output "rds_storage_alert_access_key_id" {
  value = module.rds_storage_alert.access_key_id
}

output "rds_storage_alert_secret_access_key" {
  value     = module.rds_storage_alert.secret_access_key
  sensitive = true
}

/* iam cert provision user */
output "iam_cert_provision_username" {
  value = module.iam_cert_provision_user.username
}

output "iam_cert_provision_access_key_id_prev" {
  value = module.iam_cert_provision_user.access_key_id_prev
}

output "iam_cert_provision_secret_access_key_prev" {
  value     = module.iam_cert_provision_user.secret_access_key_prev
  sensitive = true
}

output "iam_cert_provision_access_key_id_curr" {
  value = module.iam_cert_provision_user.access_key_id_curr
}

output "iam_cert_provision_secret_access_key_curr" {
  value     = module.iam_cert_provision_user.secret_access_key_curr
  sensitive = true
}

/* ecr user */
output "ecr_username" {
  value = module.ecr_user.username
}

output "ecr_access_key_id_prev" {
  value = module.ecr_user.access_key_id_prev
}

output "ecr_secret_access_key_prev" {
  value     = module.ecr_user.secret_access_key_prev
  sensitive = true
}

output "ecr_access_key_id_curr" {
  value = module.ecr_user.access_key_id_curr
}

output "ecr_secret_access_key_curr" {
  value     = module.ecr_user.secret_access_key_curr
  sensitive = true
}

/* iam roles */
output "default_profile" {
  value = module.default_role.profile_name
}

output "protobosh_profile" {
  value = module.protobosh_role.profile_name
}

output "bosh_profile" {
  value = module.bosh_role.profile_name
}

output "bosh_compilation_profile" {
  value = module.bosh_compilation_role.profile_name
}

output "protobosh_compilation_profile" {
  value = module.protobosh_compilation_role.profile_name
}


output "concourse_worker_profile" {
  value = module.concourse_worker_role.profile_name
}

output "concourse_iaas_worker_profile" {
  value = module.concourse_iaas_worker_role.profile_name
}

/* nessus elb */
output "nessus_target_group" {
  value = aws_lb_target_group.nessus_target.name
}

output "nessus_static_ip" {
  value = cidrhost(module.stack.private_cidrs[2], 71)
}

/* BOSH UAA elb */
output "opsuaa_lb_dns_name" {
  value = aws_lb.opsuaa.dns_name
}

output "opsuaa_lb_name" {
  value = aws_lb.opsuaa.name
}

output "opsuaa_target_group" {
  value = aws_lb_target_group.opsuaa_target.name
}

/* DNS static IPs */
output "staging_dns_public_ips" {
  value = [aws_eip.staging_dns_eip.*.public_ip]
}

output "dns_axfr_security_group" {
  value = module.dns.axfr_security_group
}

output "dns_public_security_group" {
  value = module.dns.public_security_group
}

#output "staging_dns_private_ips" {
#  value = local.staging_dns_private_ips
#}

#output "production_dns_public_ips" {
#  value = [aws_eip.production_dns_eip.*.public_ip]
#}

#output "production_dns_private_ips" {
#  value = local.production_dns_private_ips
#}

#output "dns_private_ips" {
#  value = concat(
#    local.production_dns_private_ips,
#    local.staging_dns_private_ips,
#  )
#}

/* Bucket names */
output "bosh_blobstore_bucket" {
  value = module.bosh_blobstore_bucket.bucket_name
}

output "protobosh_blobstore_bucket" {
  value = module.protobosh_blobstore_bucket.bucket_name
}

output "buildpack_notify_state_staging_bucket_name" {
  value = module.buildpack_notify_state_staging.bucket_name
}

output "buildpack_notify_state_production_bucket_name" {
  value = module.buildpack_notify_state_production.bucket_name
}

/* smtp security group */
output "smtp_security_group" {
  value = module.smtp.smtp_security_group
}

output "production_smtp_private_ip" {
  value = local.production_smtp_private_ip
}

# ssh key for bosh

output "bosh_default_ssh_key_name" {
  value = aws_key_pair.generated_bosh_key.key_name
}

output "bosh_default_ssh_public_key" {
  value = tls_private_key.bosh_key.public_key_openssh
}

output "bosh_default_ssh_private_key" {
  value     = tls_private_key.bosh_key.private_key_pem
  sensitive = true
}

## Experimental
output "jumpbox_psql" {
  value     = "psql \"postgres://bosh:${module.stack.bosh_rds_password}@${module.stack.bosh_rds_url_curr}/postgres\" "
  sensitive = true
}

output "jumpbox_protobosh_psql" {
  value     = "psql \"postgres://bosh:${module.stack.protobosh_rds_password}@${module.stack.protobosh_rds_url}/postgres\" "
  sensitive = true
}

output "jumpbox_instance_id" {
  value = try(module.jumpbox[0].jumpbox_instance_id, "")
}