resource "aws_ssm_parameter" "sns_topic_arn" {
  name  = "/${local.name_prefix}-${terraform.workspace}/sns_topic_arn"
  type  = "String"
  value = aws_sns_topic.alerts.arn
  depends_on = [aws_sns_topic.alerts]
  description = "SNS Topic ARN"

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

resource "aws_ssm_parameter" "cloudwatch_log_group_arn" {
  name  = "/${local.name_prefix}-${terraform.workspace}/cloudwatch_log_group_arn"
  type  = "String"
  value = aws_cloudwatch_log_group.vpc_flow_logs.arn
  depends_on = [aws_cloudwatch_log_group.vpc_flow_logs]
  description = "CloudWatch Log Group ARN"

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}