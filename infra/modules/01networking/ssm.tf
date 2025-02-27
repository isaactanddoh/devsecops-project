# Store VPC and Subnet IDs in SSM
resource "aws_ssm_parameter" "vpc_id" {
  name  = "/isaac-${terraform.workspace}/vpc_id"
  type  = "SecureString"
  value = aws_vpc.main.id
  tags  = local.common_tags
  depends_on = [aws_vpc.main]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Public Subnet IDs in SSM
resource "aws_ssm_parameter" "public_subnet_ids" {
  name  = "/isaac-${terraform.workspace}/public_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.public[*].id)
  
  
  tags  = local.common_tags
  depends_on = [aws_subnet.public]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Private Subnet IDs in SSM
resource "aws_ssm_parameter" "private_subnet_ids" {
  name  = "/isaac-${terraform.workspace}/private_subnet_ids"
  type  = "StringList"
  value = join(",", aws_subnet.private[*].id)
  
  
  tags  = local.common_tags
  depends_on = [aws_subnet.private]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store ECS Security Group ID in SSM
resource "aws_ssm_parameter" "ecs_sg_id" {
  name  = "/isaac-${terraform.workspace}/ecs_sg_id"
  type  = "String"
  value = aws_security_group.ecs_sg.id
  tags  = local.common_tags
  depends_on = [aws_security_group.ecs_sg]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
} 

# Store ALB Security Group ID in SSM
resource "aws_ssm_parameter" "alb_sg_id" {
  name  = "/isaac-${terraform.workspace}/alb_sg_id"
  type  = "String"
  value = aws_security_group.alb_sg.id
  depends_on = [aws_security_group.alb_sg]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Lambda Security Group ID in SSM
resource "aws_ssm_parameter" "lambda_sg_id" {
  name  = "/isaac-${terraform.workspace}/lambda_sg_id"
  type  = "String"
  value = aws_security_group.lambda_sg.id
  depends_on = [aws_security_group.lambda_sg]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Internet Gateway ID in SSM
resource "aws_ssm_parameter" "igw_id" {
  name  = "/${local.name_prefix}-${terraform.workspace}/igw_id"
  type  = "String"
  value = aws_internet_gateway.igw.id
  depends_on = [aws_internet_gateway.igw]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Public Route Table ID in SSM
resource "aws_ssm_parameter" "public_rt_id" {
  name  = "/${local.name_prefix}-${terraform.workspace}/public_rt_id"
  type  = "String"
  value = aws_route_table.public.id
  depends_on = [aws_route_table.public]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store Private Route Table ID in SSM
resource "aws_ssm_parameter" "private_rt_id" {
  name  = "/${local.name_prefix}-${terraform.workspace}/private_rt_id"
  type  = "String"
  value = aws_route_table.private.id
  depends_on = [aws_route_table.private]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store NAT Gateway ID in SSM
resource "aws_ssm_parameter" "nat_id" {
  name  = "/${local.name_prefix}-${terraform.workspace}/nat_id"
  type  = "String"
  value = aws_nat_gateway.nat.id
  depends_on = [aws_nat_gateway.nat]

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

