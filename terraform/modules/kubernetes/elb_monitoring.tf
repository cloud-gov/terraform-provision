resource "aws_elb" "kubernetes_monitoring_elb" {
  name = "${var.stack_description}-kubernetes-monitoring"
  subnets = ["${split(",", var.elb_subnets_public)}"]
  security_groups = ["${aws_security_group.kubernetes_elb.id}"]
  idle_timeout = 3600

  listener {
    instance_port = 80
    instance_protocol = "tcp"
    lb_port = "${var.kubernetes_grafana_port}"
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 6
    timeout = 5
    target = "TCP:${var.kubernetes_grafana_port}"
    interval = 10
  }

  tags = {
    Name = "${var.stack_description}-kubernetes"
  }
}
