resource "aws_elb" "monitoring_elb" {
  name = "${var.stack_description}-Monitoring"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]
  idle_timeout = 3600

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 3000
    instance_protocol = "HTTP"
    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "TCP:3000"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.stack_description}-Monitoring"
  }
}

resource "aws_elb" "prometheus_elb" {
  name = "${var.stack_description}-Prometheus"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]
  idle_timeout = 3600

  listener {
    lb_port = 443
    lb_protocol = "HTTPS"
    instance_port = 80
    instance_protocol = "HTTP"
    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "HTTP:80/"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags = {
    Name = "${var.stack_description}-Prometheus"
  }
}
