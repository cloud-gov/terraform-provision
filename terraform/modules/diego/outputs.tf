/* Diego Proxy ELB */

output "diego_elb_name" {
  value = aws_elb.diego_elb_main.name
}

output "diego_elb_dns_name" {
  value = aws_elb.diego_elb_main.dns_name
}

