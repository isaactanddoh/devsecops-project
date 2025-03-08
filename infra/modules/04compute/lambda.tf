# Create Lambda Function
resource "aws_lambda_function" "guardduty_lambda" {
  s3_bucket = aws_s3_bucket.lambda_bucket.bucket
  s3_key    = aws_s3_object.lambda_zip.key
  function_name    = local.lambda_function_name
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.9"
  timeout         = 30
  memory_size     = 128
  depends_on = [aws_s3_object.lambda_zip]

  # Enable X-Ray tracing
  tracing_config {
    mode = "Active"
  }

  lifecycle {
    ignore_changes = [
      s3_key, 
      vpc_config, 
      source_code_hash, 
      environment,
      tags
    ]
  }

  environment {
    variables = {
      WEB_ACL_ID = var.waf_acl_id
      SNS_TOPIC_ARN = data.aws_ssm_parameter.sns_topic_arn.value
    }
    
    #checkov:skip=CKV_AWS_116: "Ensure that AWS Lambda function is configured for a Dead Letter Queue(DLQ)"
    #checkov:skip=CKV_AWS_173: "Check encryption settings for Lambda environmental variable"
    #checkov:skip=CKV_AWS_115: "Ensure that AWS Lambda function is configured for function-level concurrent execution limit"
    #checkov:skip=CKV_AWS_272: "Ensure AWS Lambda function is configured to validate code-signing"
  }

  # Add VPC config
  vpc_config {
    subnet_ids         = split(",", data.aws_ssm_parameter.public_subnet_ids.value)
    security_group_ids = [data.aws_ssm_parameter.lambda_sg_id.value]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-guardduty-lambda"
  })
}

# Create Event Rule for Lambda
resource "aws_cloudwatch_event_rule" "guardduty_event_rule" {
  name        = "${local.name_prefix}-guardduty-event-rule"
  description = "GuardDuty event rule"
  event_pattern = jsonencode({
    source = ["aws.guardduty"]
    detail-type = ["GuardDuty Finding"]
  })
}

# Create Event Target for Lambda
resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.guardduty_event_rule.name
  target_id = "GuardDutyThreats"
  arn       = aws_lambda_function.guardduty_lambda.arn
}

