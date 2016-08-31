/* Kubernetes ELBs */
output "kubernetes_elb_name" {
  value = "${aws_elb.kubernetes_elb.name}"
}

output "kubernetes_elb_dns_name" {
  value = "${aws_elb.kubernetes_elb.dns_name}"
}

output "kubernetes_monitoring_elb_name" {
  value = "${aws_elb.kubernetes_monitoring_elb.name}"
}

output "kubernetes_monitoring_elb_dns_name" {
  value = "${aws_elb.kubernetes_monitoring_elb.dns_name}"
}

/* Kubernetes security groups */
output "kubernetes_elb_security_group" {
  value = "${aws_security_group.kubernetes_elb.id}"
}

output "kubernetes_ec2_security_group" {
  value = "${aws_security_group.kubernetes_ec2.id}"
}
