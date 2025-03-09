# Fetch VPC ID from AWS SSM Parameter Store
data "aws_ssm_parameter" "vpc_id" {
  name       = "/${local.name_prefix}-${terraform.workspace}/vpc_id"
  depends_on = [module.networking]
}

# Fetch Subnet IDs from AWS SSM Parameter Store
data "aws_ssm_parameter" "public_subnet_ids" {
  name       = "/${local.name_prefix}-${terraform.workspace}/public_subnet_ids"
  depends_on = [module.networking]
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name       = "/${local.name_prefix}-${terraform.workspace}/private_subnet_ids"
  depends_on = [module.networking]
}

# Fetch CloudWatch Log Group ARN from AWS SSM Parameter Store
data "aws_ssm_parameter" "cloudwatch_log_group_arn" {
  name       = "/${local.name_prefix}-${terraform.workspace}/cloudwatch_log_group_arn"
  depends_on = [module.monitoring]
}

# Get current AWS account ID
data "aws_caller_identity" "current" {}