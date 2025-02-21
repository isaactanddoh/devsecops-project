# Store ACM certificate ARN in SSM
resource "aws_ssm_parameter" "certificate_arn" {
  name  = "/isaac-${terraform.workspace}/certificate_arn"
  type  = "String"
  value = data.aws_iam_server_certificate.iam_cert.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store WAF ACL ARN in SSM
resource "aws_ssm_parameter" "waf_acl_arn" {
  name  = "/isaac-${terraform.workspace}/waf_acl_arn"
  type  = "String"
  value = aws_wafv2_web_acl.waf_acl.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Imported Certificate ARN in SSM
resource "aws_ssm_parameter" "imported_cert_arn" {
  name  = "/isaac-${terraform.workspace}/imported_cert_arn"
  type  = "String"
  value = data.aws_iam_server_certificate.iam_cert.arn
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

