resource "aws_cloudwatch_metric_alarm" "lb_404_anomaly_detection" {
    alarm_name = "Load Balancer High 404 Response Rate"
    comparison_operator = "GreaterThanUpperThreshold"
    evaluation_periods = 2
    threshold_metric_id = "ad1"
    alarm_description = "An alert for when the targets are returning a higher than normal rate of 404s"
    insufficient_data_actions = []
    actions_enabled = true
    ok_actions = []
    alarm_actions = [var.sns_arn]

    metric_query {
        id = "ad1"
        expression = "ANOMALY_DETECTION_BAND(m1, 5)"
        label = "HTTPCode_Target_4XX_Count (expected)"
        return_data = "true"
    }

    metric_query {
        id = "m1"
        return_data = "true"
        metric {
            metric_name = "HTTPCode_Target_4XX_Count"
            namespace = "AWS/ApplicationELB"
            period = "300"
            stat = "Sum"

            dimensions = {
              LoadBalancer = var.load_balancer_dns
            }
        }
    }

}