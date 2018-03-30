output "elb_main_dns_name" {
  value = "${aws_elb.cloudfoundry_elb_main.dns_name}"
}

output "elb_main_name" {
  value = "${aws_elb.cloudfoundry_elb_main.name}"
}

output "elb_logging_dns_name" {
  value = "${aws_elb.cloudfoundry_elb_logging.dns_name}"
}

output "elb_logging_name" {
  value = "${aws_elb.cloudfoundry_elb_logging.name}"
}

output "elb_apps_dns_name" {
  value = "${aws_elb.cloudfoundry_elb_apps.dns_name}"
}

output "elb_apps_name" {
  value = "${aws_elb.cloudfoundry_elb_apps.name}"
}

output "lb_name" {
  value = "${aws_lb.cf.name}"
}

output "lb_dns_name" {
  value = "${aws_lb.cf.dns_name}"
}

output "lb_target_group" {
  value = "${aws_lb_target_group.cf_target.name}"
}

output "cf_rds_url" {
  value = "${module.cf_database_96.rds_url}"
}

output "cf_rds_host" {
  value = "${module.cf_database_96.rds_host}"
}

output "cf_rds_port" {
  value = "${module.cf_database_96.rds_port}"
}

output "cf_rds_username" {
  value = "${module.cf_database_96.rds_username}"
}

output "cf_rds_password" {
  value = "${module.cf_database_96.rds_password}"
}

output "cf_rds_engine" {
  value = "${module.cf_database_96.rds_engine}"
}

/* Services network */
output "services_subnet_az1" {
  value = "${aws_subnet.az1_services.id}"
}
output "services_subnet_az2" {
  value = "${aws_subnet.az2_services.id}"
}

/* buckets */
output "buildpacks_bucket_name" {
  value = "${module.buildpacks.bucket_name}"
}
output "packages_bucket_name" {
  value = "${module.cc-packages.bucket_name}"
}
output "resources_bucket_name" {
  value = "${module.cc-resoures.bucket_name}"
}
output "droplets_bucket_name" {
  value = "${module.droplets.bucket_name}"
}
output "logsearch_archive_bucket_name" {
  value = "${module.logsearch-archive.bucket_name}"
}
output "etcd_backup_bucket_name" {
  value = "${module.etcd-backup.bucket_name}"
}
