# Enable GuardDuty
resource "aws_guardduty_detector" "guardduty" {
  enable = true

  
  #checkov:skip=CKV2_AWS_3: "Ensure GuardDuty is enabled to specific org/region"
}

# Create CloudWatch Event Rule for GuardDuty
resource "aws_cloudwatch_event_rule" "guardduty_event_rule" {
  name        = "GuardDutyThreats"
  description = "Capture GuardDuty threat findings and trigger Lambda"

  event_pattern = <<EOF
{
  "source": ["aws.guardduty"],
  "detail-type": ["GuardDuty Finding"]
}
EOF
}

