output "cf_rds_url" {
    value = "${module.cf_database.rds_url}"
}

output "cf_rds_host" {
    value = "${module.cf_database.rds_host}"
}

output "cf_rds_port" {
    value = "${module.cf_database.rds_port}"
}

output "elb_main_name" {
  value = "${aws_elb.diego_elb_main.name}"
}

output "elb_main_dns_name" {
  value = "${aws_elb.diego_elb_main.dns_name}"
}

