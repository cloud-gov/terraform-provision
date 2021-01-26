resource "aws_elb" "kubernetes_elb" {
  name = "${var.stack_description}-kubernetes"
  subnets = ["${var.elb_subnets}"]
  security_groups = ["${aws_security_group.kubernetes_elb.id}"]
  idle_timeout = 3600
  internal = true

  listener {
    instance_port = 6443
    instance_protocol = "tcp"
    lb_port = 6443
    lb_protocol = "tcp"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "HTTP:8080/healthz"
    interval = 30
  }

  tags = {
    Name = "${var.stack_description}-kubernetes"
  }

   access_logs = {
      bucket        = "${var.log_bucket_name}"
      bucket_prefix        = "${var.stack_description}"
      enabled       = true
    }
}
