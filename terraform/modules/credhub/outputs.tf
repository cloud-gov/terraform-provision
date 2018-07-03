/* RDS credhub Instance */
output "credhub_rds_identifier" {
  value = "${module.credhub_rds.rds_identifier}"
}

output "credhub_rds_name" {
  value = "${module.credhub_rds.rds_name}"
}

output "credhub_rds_host" {
  value = "${module.credhub_rds.rds_host}"
}

output "credhub_rds_port" {
  value = "${module.credhub_rds.rds_port}"
}

output "credhub_rds_url" {
  value = "${module.credhub_rds.rds_url}"
}

output "credhub_rds_username" {
  value = "${module.credhub_rds.rds_username}"
}

output "credhub_rds_password" {
  value = "${module.credhub_rds.rds_password}"
}
