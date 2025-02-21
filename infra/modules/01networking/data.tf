# Get available AZs in the region
data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_ssm_parameter" "public_subnet_ids" {
  name = "/isaac-${terraform.workspace}/public_subnet_ids"

  depends_on = [aws_ssm_parameter.public_subnet_ids]
}

data "aws_ssm_parameter" "private_subnet_ids" {
  name = "/isaac-${terraform.workspace}/private_subnet_ids"

  depends_on = [aws_ssm_parameter.private_subnet_ids]
}
