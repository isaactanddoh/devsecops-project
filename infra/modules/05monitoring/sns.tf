# Create SNS Topic for security alerts
resource "aws_sns_topic" "security_alerts" {
  name = "${local.name_prefix}-security-alerts"
  
  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-security-alerts"
  })

  #checkov:skip=CKV_AWS_26: "Ensure all data stored in the SNS topic is encrypted"
}

# Create email subscription
resource "aws_sns_topic_subscription" "security_alerts_email" {
  topic_arn = aws_sns_topic.security_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address

  #checkov:skip=CKV_AWS_26: "Ensure all data stored in the SNS topic is encrypted"
} 

# SNS Topic for Alerts
resource "aws_sns_topic" "alerts" {
  name = "${local.name_prefix}-backend-alerts"

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-backend-alerts"
  })

  #checkov:skip=CKV_AWS_26: "Ensure all data stored in the SNS topic is encrypted"
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email_address

  #checkov:skip=CKV_AWS_26: "Ensure all data stored in the SNS topic is encrypted"
} 