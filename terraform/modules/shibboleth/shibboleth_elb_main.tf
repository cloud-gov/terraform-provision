resource "aws_lb_target_group" "shibboleth" {
  name     = "${var.stack_description}-shibboleth"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    healthy_threshold   = 2
    interval            = 15
    path                = "/shibboleth"
    timeout             = 10
    unhealthy_threshold = 2
    matcher             = 200
  }

  stickiness {
    type    = "lb_cookie"
    enabled = true
  }
}

resource "aws_lb_listener_rule" "shibboleth" {
  count = length(var.hosts)

  listener_arn = var.listener_arn
  priority     = 100 + count.index

  action {
    target_group_arn = aws_lb_target_group.shibboleth.arn
    type             = "forward"
  }

  condition {
    host_header {
      # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
      # force an interpolation expression to be interpreted as a list by wrapping it
      # in an extra set of list brackets. That form was supported for compatibility in
      # v0.11, but is no longer supported in Terraform v0.12.
      #
      # If the expression in the following list itself returns a list, remove the
      # brackets to avoid interpretation as a list of lists. If the expression
      # returns a single list item then leave it as-is and remove this TODO comment.
      values = [element(var.hosts, count.index)]
    }
  }
}

