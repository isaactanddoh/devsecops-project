# Add SSM parameter for target group ARN
resource "aws_ssm_parameter" "alb_target_group_arn" {
  name  = "/isaac-${terraform.workspace}/alb_target_group_arn"
  type  = "String"
  value = aws_lb_target_group.ecs_target_group.arn

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

resource "aws_ssm_parameter" "alb_arn" {
  name  = "/isaac-${terraform.workspace}/alb_arn"
  type  = "String"
  value = aws_lb.alb.arn

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

resource "aws_ssm_parameter" "alb_zone_id" {
  name  = "/isaac-${terraform.workspace}/alb_zone_id"
  type  = "String"
  value = aws_lb.alb.zone_id
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

resource "aws_ssm_parameter" "alb_dns_name" {
  name  = "/isaac-${terraform.workspace}/alb_dns_name"
  type  = "String"
  value = aws_lb.alb.dns_name
  tags  = local.common_tags

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

