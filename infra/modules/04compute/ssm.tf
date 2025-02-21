# Store Cluster ARN
resource "aws_ssm_parameter" "ecs_cluster_arn" {
  name  = "/isaac-${terraform.workspace}/ecs_cluster_arn"
  type  = "String"
  value = aws_ecs_cluster.ecs_cluster.arn
  tags  = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store ECS Cluster ID
resource "aws_ssm_parameter" "ecs_cluster_id" {
  name  = "/isaac-${terraform.workspace}/ecs_cluster_id"
  type  = "String"
  value = aws_ecs_cluster.ecs_cluster.id
  tags  = local.common_tags
  depends_on = [aws_ecs_cluster.ecs_cluster]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}

# Store ECS Task Definition ARN
resource "aws_ssm_parameter" "ecs_task_definition_arn" {
  name  = "/isaac-${terraform.workspace}/ecs_task_definition_arn"
  type  = "String"
  value = aws_ecs_task_definition.task.arn
  tags  = local.common_tags
  depends_on = [aws_ecs_task_definition.task]

  #checkov:skip=CKV2_AWS_34: "AWS SSM Parameter should be Encrypted"
}




