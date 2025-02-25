# IAM Policy for CloudWatch Dashboard Read Access
resource "aws_iam_policy" "cloudwatch_dashboard_readonly" {
  name        = var.policy_name
  description = "Allows read-only access to CloudWatch Dashboards"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "cloudwatch:ListDashboards",
          "cloudwatch:GetDashboard",
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "cloudwatch:GetMetricStatistics",
          "cloudwatch:ListMetrics"
        ]
        Resource = "*"
      }
    ]
  })

  #checkov:skip=CKV_AWS_355: "Ensure no IAM policies documents allow "*" as a statement's resource for restrictable actions"
}

# IAM Group for CloudWatch Access
resource "aws_iam_group" "cloudwatch_dashboard_users" {
  name = var.group_name
}

# Attach Policy to Group
resource "aws_iam_group_policy_attachment" "attach_dashboard_policy" {
  group      = aws_iam_group.cloudwatch_dashboard_users.name
  policy_arn = aws_iam_policy.cloudwatch_dashboard_readonly.arn
}

# AWS SSO Permission Set (if using AWS IAM Identity Center)
resource "aws_ssoadmin_permission_set" "cloudwatch_readonly" {
  count           = var.enable_sso ? 1 : 0
  name            = "CloudWatchReadOnly"
  instance_arn    = data.aws_ssoadmin_instances.sso.arns[0]
  description     = "Read-only access to CloudWatch Dashboards"
  session_duration = "PT4H"
}

# Attach AWS-Managed CloudWatch Read-Only Policy
resource "aws_ssoadmin_managed_policy_attachment" "attach_dashboard_policy_sso" {
  count            = var.enable_sso ? 1 : 0
  instance_arn     = data.aws_ssoadmin_instances.sso.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.cloudwatch_readonly[0].arn
  managed_policy_arn = "arn:aws:iam::aws:policy/CloudWatchReadOnlyAccess"
}
