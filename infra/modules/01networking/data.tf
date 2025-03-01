# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

# Get public subnet IDs
data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/${local.name_prefix}-${terraform.workspace}/public_subnet_ids"

  depends_on = [aws_ssm_parameter.public_subnet_ids]
}

# Get private subnet IDS
data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/${local.name_prefix}-${terraform.workspace}/private_subnet_ids"

  depends_on = [aws_ssm_parameter.private_subnet_ids]
}
