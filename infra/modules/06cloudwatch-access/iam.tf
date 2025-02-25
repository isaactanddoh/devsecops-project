# Create IAM role for CloudWatch access
resource "aws_iam_role" "cloudwatch_access" {
  name = local.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Create CloudWatch access policy
resource "aws_iam_policy" "cloudwatch_access" {
  name        = local.policy_name
  description = "Environment-specific policy for CloudWatch dashboard access"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = local.cloudwatch_permissions[var.environment]
        Resource = "*"
      }
    ]
  })

  tags = local.common_tags
}

# Create IAM group for CloudWatch users
resource "aws_iam_group" "cloudwatch_users" {
  name = local.group_name
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudwatch_access" {
  role       = aws_iam_role.cloudwatch_access.name
  policy_arn = aws_iam_policy.cloudwatch_access.arn
}

# Attach policy to group
resource "aws_iam_group_policy_attachment" "cloudwatch_access" {
  group      = aws_iam_group.cloudwatch_users.name
  policy_arn = aws_iam_policy.cloudwatch_access.arn
}

# Create SSO permission set if enabled
resource "aws_ssoadmin_permission_set" "cloudwatch" {
  count             = var.enable_sso ? 1 : 0
  name              = "${local.name_prefix}-cloudwatch-access"
  description       = "Environment-specific CloudWatch dashboard access"
  instance_arn      = data.aws_ssoadmin_instances.sso.arns[0]
  session_duration  = "PT8H"

  tags = local.common_tags
}

# Attach CloudWatch policy to SSO permission set
resource "aws_ssoadmin_permission_set_inline_policy" "cloudwatch" {
  count              = var.enable_sso ? 1 : 0
  instance_arn       = data.aws_ssoadmin_instances.sso.arns[0]
  permission_set_arn = aws_ssoadmin_permission_set.cloudwatch[0].arn
  inline_policy      = aws_iam_policy.cloudwatch_access.policy
} 