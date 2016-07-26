
output "elb_main_dns_name" {
  value = "${aws_elb.cloudfoundry_elb_main.dns_name}"
}

output "elb_main_name" {
  value = "${aws_elb.cloudfoundry_elb_main.name}"
}

output "elb_apps_dns_name" {
  value = "${aws_elb.cloudfoundry_elb_apps.dns_name}"
}

output "elb_apps_name" {
  value = "${aws_elb.cloudfoundry_elb_apps.name}"
}

output "cf_rds_url" {
    value = "${module.cf_database.rds_url}"
}

output "cf_rds_host" {
    value = "${module.cf_database.rds_host}"
}

output "cf_rds_port" {
    value = "${module.cf_database.rds_port}"
}

/* Services network */
output "services_subnet_az1" {
  value = "${aws_subnet.az1_services.id}"
}
output "services_subnet_az2" {
  value = "${aws_subnet.az2_services.id}"
}

/* Monitoring */
output "monitoring_elb_dns_name" {
  value = "${aws_elb.monitoring_elb.dns_name}"
}

output "monitoring_elb_name" {
  value = "${aws_elb.monitoring_elb.name}"
}

output "monitoring_elb_security_group" {
  value = "${aws_security_group.monitoring.id}"
}

/* Logsearch */
output "logsearch_elb_dns_name" {
  value = "${aws_elb.logsearch_elb.dns_name}"
}

output "logsearch_elb_name" {
  value = "${aws_elb.logsearch_elb.name}"
}
