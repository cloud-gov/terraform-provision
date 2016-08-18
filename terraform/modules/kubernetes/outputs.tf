/* Kubernetes ELB */
output "kubernetes_elb_name" {
  value = "${aws_elb.kubernetes_elb.name}"
}

output "kubernetes_elb_dns_name" {
  value = "${aws_elb.kubernetes_elb.dns_name}"
}

/* Kubernetes security group */
output "kubernetes_security_group" {
  value = "${aws_security_group.kubernetes.id}"
}
