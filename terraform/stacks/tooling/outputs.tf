
/* VPC */
output "vpc_id" {
    value = "${module.stack.vpc_id}"
}
output "vpc_cidr" {
    value = "${module.stack.vpc_cidr}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.stack.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.stack.private_subnet_az2}"
}
output "private_route_table_az1" {
  value = "${module.stack.private_route_table_az1}"
}
output "private_route_table_az2" {
  value = "${module.stack.private_route_table_az2}"
}

/* Public network */
output "public_subnet_az1" {
  value = "${module.stack.public_subnet_az1}"
}
output "public_subnet_az2" {
  value = "${module.stack.public_subnet_az2}"
}
output "public_route_table" {
  value = "${module.stack.public_route_table}"
}

/* Security Groups */
output "bosh_security_group" {
  value = "${module.stack.bosh_security_group}"
}
output "local_vpc_traffic_security_group" {
    value = "${module.stack.local_vpc_traffic_security_group}"
}
output "web_traffic_security_group" {
  value = "${module.stack.web_traffic_security_group}"
}
output "nessus_security_group" {
  value = "${aws_security_group.nessus_traffic.id}"
}

/* RDS Network */
output "rds_subnet_az1" {
    value = "${module.stack.rds_subnet_az1}"
}
output "rds_subnet_az2" {
    value = "${module.stack.rds_subnet_az2}"
}
output "rds_subnet_group" {
    value = "${module.stack.rds_subnet_group}"
}
output "rds_mysql_security_group" {
  value = "${module.stack.rds_mysql_security_group}"
}
output "rds_postgres_security_group" {
  value = "${module.stack.rds_postgres_security_group}"
}

/* RDS Bosh Instance */
output "bosh_rds_url" {
  value = "${module.stack.bosh_rds_url}"
}
output "bosh_rds_host" {
  value = "${module.stack.bosh_rds_host}"
}
output "bosh_rds_port" {
  value = "${module.stack.bosh_rds_port}"
}


/* Production Concourse */
output "production_concourse_subnet" {
  value = "${module.concourse_production.concourse_subnet}"
}
output "production_concourse_security_group" {
  value = "${module.concourse_production.concourse_security_group}"
}
output "production_concourse_rds_url" {
  value = "${module.concourse_production.concourse_rds_url}"
}
output "production_concourse_elb_dns_name" {
  value = "${module.concourse_production.concourse_elb_dns_name}"
}
output "production_concourse_elb_name" {
  value = "${module.concourse_production.concourse_elb_name}"
}

/* Staging Concourse */
output "staging_concourse_subnet" {
  value = "${module.concourse_staging.concourse_subnet}"
}
output "staging_concourse_security_group" {
  value = "${module.concourse_staging.concourse_security_group}"
}
output "staging_concourse_rds_url" {
  value = "${module.concourse_staging.concourse_rds_url}"
}
output "staging_concourse_elb_dns_name" {
  value = "${module.concourse_staging.concourse_elb_dns_name}"
}
output "staging_concourse_elb_name" {
  value = "${module.concourse_staging.concourse_elb_name}"
}

/* master bosh user */
output "master_bosh_username" {
  value = "${module.master_bosh_user.username}"
}
output "master_bosh_access_key_id" {
  value = "${module.master_bosh_user.access_key_id}"
}
output "master_bosh_secret_access_key" {
  value = "${module.master_bosh_user.secret_access_key}"
}

/* tooling bosh user */
output "tooling_bosh_username" {
  value = "${module.tooling_bosh_user.username}"
}
output "tooling_bosh_access_key_id" {
  value = "${module.tooling_bosh_user.access_key_id}"
}
output "tooling_bosh_secret_access_key" {
  value = "${module.tooling_bosh_user.secret_access_key}"
}

/* ci user to access bosh secrets */
output "ci_username" {
  value = "${module.ci_user.username}"
}
output "ci_access_key_id" {
  value = "${module.ci_user.access_key_id}"
}
output "ci_secret_access_key" {
  value = "${module.ci_user.secret_access_key}"
}

/* release user to write release blobs */
output "release_username" {
  value = "${module.release_user.username}"
}
output "release_access_key_id" {
  value = "${module.release_user.access_key_id}"
}
output "release_secret_access_key" {
  value = "${module.release_user.secret_access_key}"
}

/* s3 broker user */
output "s3_broker_username" {
  value = "${module.s3_broker_user.username}"
}
output "s3_broker_access_key_id" {
  value = "${module.s3_broker_user.access_key_id}"
}
output "s3_broker_secret_access_key" {
  value = "${module.s3_broker_user.secret_access_key}"
}

/* cf cc user */
output "cf_username" {
  value = "${module.cf_user.username}"
}
output "cf_access_key_id" {
  value = "${module.cf_user.access_key_id}"
}
output "cf_secret_access_key" {
  value = "${module.cf_user.secret_access_key}"
}

/* cloudwatch user */
output "awslogs_username" {
  value = "${module.cloudwatch_user.username}"
}
output "awslogs_access_key_id" {
  value = "${module.cloudwatch_user.access_key_id}"
}
output "awslogs_secret_access_key" {
  value = "${module.cloudwatch_user.secret_access_key}"
}

/* nessus elb */
output "nessus_elb_dns_name" {
  value = "${aws_elb.nessus_elb.dns_name}"
}

output "nessus_elb_name" {
  value = "${aws_elb.nessus_elb.name}"
}


