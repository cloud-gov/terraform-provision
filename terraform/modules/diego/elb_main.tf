/*
 * Variables required:
 *   stack_description
 *   elb_subnets
 *   elb_security_groups
 */


resource "aws_elb" "diego_elb_main" {
  name = "${var.stack_description}-diego-proxy"
  subnets = ["${split(",", var.elb_subnets)}"]
  security_groups = ["${split(",", var.elb_security_groups)}"]

  listener {
    lb_port = 2222
    lb_protocol = "SSL"
    instance_port = 2222
    instance_protocol = "SSL"

    ssl_certificate_id = "arn:${var.aws_partition}:iam::${var.account_id}:server-certificate/${var.elb_main_cert_name}"
  }

  health_check {
    healthy_threshold = 2
    interval = 5
    target = "SSL:2222"
    timeout = 4
    unhealthy_threshold = 3
  }

  tags =  {
    Name = "${var.stack_description}-Diego-Proxy-ElB"
  }

}
