/* VPC */
output "vpc_id" {
  value = "${module.vpc.vpc_id}"
}
output "vpc_cidr" {
  value = "${module.vpc.vpc_cidr}"
}
output "vpc_cidr_dns" {
  value = "${cidrhost("${module.vpc.vpc_cidr}", 2)}"
}

/* Private network */
output "private_subnet_az1" {
  value = "${module.vpc.private_subnet_az1}"
}
output "private_subnet_az2" {
  value = "${module.vpc.private_subnet_az2}"
}
output "private_subnet_cidr_az1" {
  value = "${module.vpc.private_cidr_az1}"
}
output "private_subnet_cidr_az2" {
  value = "${module.vpc.private_cidr_az2}"
}
output "private_subnet_gateway_az1" {
  value = "${cidrhost("${module.vpc.private_cidr_az1}", 1)}"
}
output "private_subnet_gateway_az2" {
  value = "${cidrhost("${module.vpc.private_cidr_az2}", 1)}"
}
output "private_subnet_reserved_az1" {
  value = "${cidrhost("${module.vpc.private_cidr_az1}", 0)} - ${cidrhost("${module.vpc.private_cidr_az1}", 3)}"
}
output "private_subnet_reserved_az2" {
  value = "${cidrhost("${module.vpc.private_cidr_az2}", 0)} - ${cidrhost("${module.vpc.private_cidr_az2}", 3)}"
}
output "private_route_table_az1" {
  value = "${module.vpc.private_route_table_az1}"
}
output "private_route_table_az2" {
  value = "${module.vpc.private_route_table_az2}"
}

/* Security Groups */
output "bosh_security_group" {
  value = "${module.vpc.bosh_security_group}"
}
