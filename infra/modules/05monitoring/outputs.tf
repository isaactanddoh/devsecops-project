# SNS Topic ARN
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alerts"
  value = aws_sns_topic.alerts.arn
}

# CloudWatch outputs
output "log_groups_configured" {
  description = "Status of CloudWatch log groups configuration"
  value       = aws_cloudwatch_log_group.ecs_logs != null
}

output "alarms_configured" {
  description = "Status of CloudWatch alarms configuration"
  value       = length(aws_cloudwatch_metric_alarm.cpu_utilization) > 0
}

output "sns_topics_configured" {
  description = "Status of SNS topics configuration"
  value       = aws_sns_topic.alerts.arn != null
}

output "flow_logs_config" {
  description = "Flow logs configuration details"
  value = {
    log_group_name = aws_cloudwatch_log_group.vpc_flow_logs.name
    enabled        = true  # Since the resource will be created by Terraform
    retention_days = aws_cloudwatch_log_group.vpc_flow_logs.retention_in_days
  }

  precondition {
    condition     = var.flow_logs_retention_days > 0
    error_message = "Flow logs retention period must be greater than 0 days"
  }
}


output "log_group_name" {
  description = "Name of the CloudWatch Log Group"
  value       = aws_cloudwatch_log_group.ecs_logs.name
}

output "cpu_utilization_alarm_enabled" {
  description = "Whether CPU utilization alarm is enabled"
  value       = try(aws_cloudwatch_metric_alarm.cpu_utilization.id != "", false)
}

output "memory_utilization_alarm_enabled" {
  description = "Whether memory utilization alarm is enabled"
  value       = try(aws_cloudwatch_metric_alarm.memory_utilization.id != "", false)
}


