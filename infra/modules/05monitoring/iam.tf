# Create IAM Role for VPC Flow Logs
resource "aws_iam_role" "vpc_flow_logs_role" {
  name = "VPCFlowLogsRole"
  assume_role_policy = file("${path.root}/policies/vpc-flow-logs-assume-role-policy.json")
}

# Attach IAM Policy to Allow Logging to CloudWatch
resource "aws_iam_role_policy" "vpc_flow_logs_policy" {
  name = "VPCFlowLogsPolicy"
  role = aws_iam_role.vpc_flow_logs_role.id
  policy = templatefile("${path.root}/policies/vpc-flow-logs-policy.json", {
    log_group_arn = aws_cloudwatch_log_group.vpc_flow_logs.arn
  })
}

# SNS Topic Policy
resource "aws_sns_topic_policy" "default" {
  arn = aws_sns_topic.alerts.arn

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudWatchAlarms"
        Effect = "Allow"
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        }
        Action   = "SNS:Publish"
        Resource = aws_sns_topic.alerts.arn
      }
    ]
  })
}