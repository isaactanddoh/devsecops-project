# Add anomaly detection
resource "aws_cloudwatch_metric_alarm" "cpu_anomaly" {
  alarm_name          = "${local.name_prefix}-cpu-anomaly"
  comparison_operator = "GreaterThanUpperThreshold"
  evaluation_periods  = 2
  threshold_metric_id = "ad1"
  alarm_description   = "CPU utilization is abnormally high"
  alarm_actions      = [data.aws_sns_topic.alerts.arn]

  metric_query {
    id          = "m1"
    return_data = true
    metric {
      metric_name = "CPUUtilization"
      namespace   = "AWS/ECS"
      period     = 300
      stat       = "Average"
      dimensions = {
        ClusterName = aws_ecs_cluster.ecs_cluster.name
        ServiceName = aws_ecs_service.ecs_service.name
      }
    }
  }

  metric_query {
    id          = "ad1"
    expression  = "ANOMALY_DETECTION_BAND(m1, 2)"
    label       = "CPUUtilization (Expected)"
    return_data = true
  }

  tags = local.common_tags
}