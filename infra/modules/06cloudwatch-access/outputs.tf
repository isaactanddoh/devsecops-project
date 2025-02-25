# Output CloudWatch Dashboard URL
output "cloudwatch_dashboard_url" {
  description = "Direct URL to the CloudWatch Dashboard"
  value       = "https://console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${local.dashboard_name}"
}

# Output CloudWatch Access Role ARN
output "cloudwatch_access_role_arn" {
  description = "ARN of the CloudWatch access IAM role"
  value       = aws_iam_role.cloudwatch_access.arn
}

# Output CloudWatch Access Policy ARN
output "cloudwatch_access_policy_arn" {
  description = "ARN of the CloudWatch access IAM policy"
  value       = aws_iam_policy.cloudwatch_access.arn
}

# Output CloudWatch Users Group Name
output "cloudwatch_users_group_name" {
  description = "Name of the CloudWatch users IAM group"
  value       = aws_iam_group.cloudwatch_users.name
}

# Output SSO Permission Set ARN
output "sso_permission_set_arn" {
  description = "ARN of the SSO permission set for CloudWatch access"
  value       = var.enable_sso ? aws_ssoadmin_permission_set.cloudwatch[0].arn : null
}

# Output Environment Configuration
output "environment_config" {
  description = "Environment-specific configuration details"
  value = {
    environment      = var.environment
    retention_days   = local.retention_days
    permissions      = local.cloudwatch_permissions[var.environment]
    dashboard_name   = local.dashboard_name
    sso_enabled     = var.enable_sso
  }
}

# Output Dashboard Name
output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = local.dashboard_name
}
