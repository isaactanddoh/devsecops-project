# Get Route 53 Hosted Zone
data "aws_route53_zone" "primary" {
  name         = "thekloudwiz.com"
  private_zone = false
}

# Get AWS account info
data "aws_caller_identity" "current" {}
data "aws_elb_service_account" "main" {}

# Add data sources for SSM parameters
data "aws_ssm_parameter" "alb_sg_id" {
  name = "/${local.name_prefix}-${terraform.workspace}/alb_sg_id"
}

# Fetch Certificate ARN from SSM Parameter Store
data "aws_ssm_parameter" "certificate_arn" {
  name = "/${local.name_prefix}-${terraform.workspace}/certificate_arn"
}

# Fetch VPC ID from SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name = "/${local.name_prefix}-${terraform.workspace}/vpc_id"
}

# Fetch Subnet IDs from SSM Parameter Store
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${local.name_prefix}-${terraform.workspace}/public_subnet_ids"
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${local.name_prefix}-${terraform.workspace}/private_subnet_ids"
}

# Fetch WAF ACL ARN from SSM Parameter Store
data "aws_ssm_parameter" "waf_acl_arn" {
  name = "/${local.name_prefix}-${terraform.workspace}/waf_acl_arn"
}

# Get ACM Certificate
data "aws_acm_certificate" "acm_cert" {
  domain   = var.wildcard_domain_name
  statuses = ["ISSUED"]
  types    = ["AMAZON_ISSUED"]
}

# Get IAM Certificate
data "aws_iam_server_certificate" "iam_cert" {
  name = var.iam_cert_name
}

