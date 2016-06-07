
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

