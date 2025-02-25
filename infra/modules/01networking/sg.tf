# Create Security Group for ALB
resource "aws_security_group" "alb_sg" {
  name        = local.alb_sg_name
  description = "Security group for ALB"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  ingress {
    description = "Allow HTTPS traffic to ALB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }

  egress {
    description = "Allow all traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = local.alb_sg_name
  })
  #checkov:skip=CKV_AWS_260: "Ensure no security groups allow ingress from 0.0.0.0:0 to port 80"
  #checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
}

# Create Security Group for ECS
resource "aws_security_group" "ecs_sg" {
  name        = local.ecs_sg_name
  description = "Security group for ECS tasks"
  vpc_id      = aws_ssm_parameter.vpc_id.value

  ingress {
    description = "Allow traffic from ALB"
    from_port       = var.container_port
    to_port         = var.container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Only allow traffic from ALB
  }

  ingress {
    description = "Allow HTTP traffic from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Only allow traffic from ALB
  }

  ingress {
    description = "Allow HTTPS traffic from ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Only allow traffic from ALB
  }

  egress {
    description = "Allow all traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = local.ecs_sg_name
  })
  #checkov:skip=CKV_AWS_23: "Ensure all security groups block ingress from 0.0.0.0/0 and egress to 0.0.0.0/0"
  #checkov:skip=CKV_AWS_260: "Ensure public internet (0.0.0.0/0) cannot access port 80"
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
}

# Create Security Group for Lambda
resource "aws_security_group" "lambda_sg" {
  name        = "${local.name_prefix}-lambda-sg"
  description = "Security group for Lambda function"
  vpc_id      = aws_ssm_parameter.vpc_id.value
  depends_on = [aws_ssm_parameter.vpc_id]

  lifecycle {
    ignore_changes = [name, vpc_id]
    create_before_destroy = true
  }

  egress {
    description = "Allow all traffic to anywhere"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lambda-sg"
  })
  #checkov:skip=CKV_AWS_23: "Ensure every security group and rule has a description"
  #checkov:skip=CKV2_AWS_5: "Ensure that Security Groups are attached to another resource"
  #checkov:skip=CKV_AWS_382: "Ensure no security groups allow egress from 0.0.0.0:0 to port -1"
}