output "star_18f_gov_elb_name" {
  value = "${join(",", aws_elb.star_18f_gov_elb.*.name)}"
}

output "star_18f_gov_elb_dns_name" {
  value = "${join(",", aws_elb.star_18f_gov_elb.*.dns_name)}"
}
