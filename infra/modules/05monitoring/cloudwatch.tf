# Create CloudWatch Log Group for Flow Logs
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "/aws/vpc/flow-logs/${data.aws_ssm_parameter.vpc_id.value}"
  retention_in_days = var.flow_logs_retention_days

  lifecycle {
    ignore_changes = [ name ]
  }

  tags = merge(local.common_tags, {
    Name = "VPC Flow Logs Group"
  })

  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
  #checkov:skip=CKV_AWS_338: "Ensure CloudWatch log groups retains logs for at least 1 year"
}

# Enable VPC Flow Logs
resource "aws_flow_log" "vpc_flow_logs" {
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  vpc_id              = data.aws_ssm_parameter.vpc_id.value
  iam_role_arn        = aws_iam_role.vpc_flow_logs_role.arn

  lifecycle {
    ignore_changes = [ vpc_id, log_destination ]
  }
}

# Application-specific alarms
resource "aws_cloudwatch_metric_alarm" "api_latency" {
  alarm_name          = "${local.name_prefix}-api-latency"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic          = "Average"
  threshold          = 1
  alarm_description  = "API latency is too high"
  alarm_actions      = [aws_sns_topic.alerts.arn]

  dimensions = {
    LoadBalancer = data.aws_lb.alb.arn_suffix
  }

  tags = local.common_tags
}

resource "aws_cloudwatch_log_group" "app_logs" {
  name = "/aws/ecs/app-${local.ecs_cluster_name}-app-logs"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.ecs_cluster_name}-app-logs"
  })

  lifecycle {
    ignore_changes = [ name ]
    create_before_destroy = true
  }

  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/aws/ecs/${local.ecs_cluster_name}-logs"
  retention_in_days = var.log_retention_days

  tags = merge(local.common_tags, {
    Name = "${local.ecs_cluster_name}-logs"
  })

  lifecycle {
    ignore_changes = [ name ]
    create_before_destroy = true
  }

  #checkov:skip=CKV_AWS_66: "Ensure that CloudWatch Log Group specifies retention days"
  #checkov:skip=CKV_AWS_158: "Ensure that CloudWatch Log Group is encrypted by KMS"
}

# Add log metric filter for critical errors
resource "aws_cloudwatch_log_metric_filter" "error_metric" {
  name           = "${local.name_prefix}-error-metric"
  pattern        = "[timestamp, requestid, level=ERROR*, message]"
  log_group_name = aws_cloudwatch_log_group.ecs_logs.name

  metric_transformation {
    name      = "${local.name_prefix}-error-count"
    namespace = "${local.name_prefix}/Errors"
    value     = "1"
    default_value = "0"
  }

  depends_on = [aws_cloudwatch_log_group.ecs_logs]
}

# CloudWatch Metric Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  alarm_name          = "${local.ecs_cluster_name}-cpu-utilization"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period             = "300"
  statistic          = "Average"
  threshold          = var.cpu_threshold
  alarm_description  = "This metric monitors ECS CPU utilization"

  dimensions = {
    ClusterName = local.ecs_cluster_name
    ServiceName = "${local.ecs_cluster_name}-service"
  }

  alarm_actions = [aws_sns_topic.alerts.arn]
  ok_actions    = [aws_sns_topic.alerts.arn]

  tags = merge(local.common_tags, {
    Name = "${local.ecs_cluster_name}-cpu-utilization"
  })
}