/* Allow Kubernetes VMs to access BOSH registry */
resource "aws_security_group_rule" "bosh_registry" {
  type = "ingress"
  from_port = 25777
  to_port = 25777
  protocol = "tcp"
  source_security_group_id = "${aws_security_group.kubernetes_ec2.id}"
  security_group_id = "${var.target_bosh_security_group}"
}
