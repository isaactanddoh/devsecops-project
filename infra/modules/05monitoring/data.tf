data "aws_ssm_parameter" "vpc_id" {
  name = "/isaac-${terraform.workspace}/vpc_id"
}

data "aws_lb" "alb" {
  name = "${local.name_prefix}-alb"
}