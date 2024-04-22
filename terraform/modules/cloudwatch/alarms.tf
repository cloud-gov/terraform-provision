resource "aws_cloudwatch_metric_alarm" "lb_4XX_anomaly_detection" {
  alarm_name                = "${var.stack_description} CF Load Balancer High 4XX Response Rate"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = 5
  datapoints_to_alarm       = 3
  threshold_metric_id       = "ad1"
  alarm_description         = "Alerts when the targets are returning a higher than normal rate of 4XX responses"
  insufficient_data_actions = []
  actions_enabled           = true
  ok_actions                = []
  alarm_actions             = [var.cg_platform_notifications_arn]
  treat_missing_data        = "missing"

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 20)"
    label       = "HTTPCode_Target_4XX_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "HTTPCode_Target_4XX_Count"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.load_balancer_dns
      }
    }
  }

}

resource "aws_cloudwatch_metric_alarm" "load_balancer_request_spike" {
  alarm_name                = "${var.stack_description} Load Balancer Spike in Requests"
  comparison_operator       = "GreaterThanUpperThreshold"
  evaluation_periods        = 1
  datapoints_to_alarm       = 1
  threshold_metric_id       = "e1"
  alarm_description         = "There has been a large spike in load balancer requests to the ${var.stack_description} cloudfoundry apps loadbalancer"
  insufficient_data_actions = []
  actions_enabled           = var.stack_description == "production" ? true : false
  ok_actions                = []
  alarm_actions             = [var.cg_platform_notifications_arn, var.cg_platform_slack_notifications_arn]
  treat_missing_data        = "missing"

  metric_query {
    id          = "e1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 10)"
    label       = "Load_Balancer_Count (expected)"
    return_data = "true"
  }

  metric_query {
    id          = "m1"
    return_data = "true"
    metric {
      metric_name = "RequestCount"
      namespace   = "AWS/ApplicationELB"
      period      = "60"
      stat        = "Sum"

      dimensions = {
        LoadBalancer = var.load_balancer_dns
      }
    }
  }

}
