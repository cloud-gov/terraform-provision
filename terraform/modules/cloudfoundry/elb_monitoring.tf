resource "aws_elb" "monitoring_elb" {
  name = "${var.stack_description}-Monitoring"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]
  idle_timeout = 3600

  /* TODO: Make sure that the cert can ref either "arn:aws" or "arn:aws-us-gov" */
  listener {
    instance_port = 3000
    instance_protocol = "http"
    lb_port = 443
    lb_protocol = "ssl"
    ssl_certificate_id = "arn:aws-us-gov:iam::${var.account_id}:server-certificate/${var.monitoring_elb_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 10
    timeout = 5
    target = "http:3000"
    interval = 30
  }

  tags =  {
    Name = "${var.stack_description}-Monitoring"
  }

}

