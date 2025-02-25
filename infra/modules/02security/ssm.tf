# Store ACM certificate ARN in SSM
resource "aws_ssm_parameter" "certificate_arn" {
  name  = "/isaac-${terraform.workspace}/certificate_arn"
  type  = "SecureString"
  value = data.aws_iam_server_certificate.iam_cert.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  #checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
}

# Store WAF ACL ARN in SSM
resource "aws_ssm_parameter" "waf_acl_arn" {
  name  = "/isaac-${terraform.workspace}/waf_acl_arn"
  type  = "SecureString"
  value = aws_wafv2_web_acl.waf_acl.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  #checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
}

# Store Imported Certificate ARN in SSM
resource "aws_ssm_parameter" "imported_cert_arn" {
  name  = "/isaac-${terraform.workspace}/imported_cert_arn"
  type  = "SecureString"
  value = data.aws_iam_server_certificate.iam_cert.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  #checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
}


# Store WAF ACL ID in SSM
resource "aws_ssm_parameter" "waf_acl_id" {
  name  = "/isaac-${terraform.workspace}/waf_acl_id"
  type  = "SecureString"
  value = aws_wafv2_web_acl.waf_acl.id
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  #checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
}

# Store GuardDuty Detector ID in SSM
resource "aws_ssm_parameter" "guardduty_detector_id" {
  name  = "/isaac-${terraform.workspace}/guardduty_detector_id"
  type  = "SecureString"
  value = aws_guardduty_detector.guardduty.id
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
  #checkov:skip=CKV_AWS_337: "Ensure SSM parameters are using KMS CMK"
}






