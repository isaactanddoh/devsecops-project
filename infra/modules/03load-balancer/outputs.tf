# ALB outputs
output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.alb.dns_name
}

output "alb_target_group_arn" {
  description = "The ARN of the ALB Target Group"
  value       = aws_lb_target_group.ecs_target_group.arn
}

output "access_logs_enabled" {
  description = "Status of ALB access logs"
  value       = aws_lb.alb.access_logs[0].enabled
}

output "ssl_policy" {
  description = "SSL policy used by the ALB"
  value       = aws_lb_listener.https_listener.ssl_policy
}

output "deletion_protection_enabled" {
  description = "Status of deletion protection"
  value       = aws_lb.alb.enable_deletion_protection
}

# Add ALB ARN suffix for CloudWatch metrics
output "alb_arn_suffix" {
  description = "ARN Suffix of the ALB for CloudWatch metrics"
  value       = aws_lb.alb.arn_suffix
}
