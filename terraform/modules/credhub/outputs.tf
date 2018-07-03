/* RDS credhub Instance */
output "credhub_rds_identifier" {
  value = "${module.credhub.rds_identifier}"
}

output "credhub_rds_name" {
  value = "${module.credhub.rds_name}"
}

output "credhub_rds_host" {
  value = "${module.credhub.rds_host}"
}

output "credhub_rds_port" {
  value = "${module.credhub.rds_port}"
}

output "credhub_rds_url" {
  value = "${module.credhub.rds_url}"
}

output "credhub_rds_username" {
  value = "${module.credhub.rds_username}"
}

output "credhub_rds_password" {
  value = "${module.credhub.rds_password}"
}
