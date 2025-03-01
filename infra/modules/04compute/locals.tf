locals {
  # Naming convention for resources
  name_prefix = "${var.project_name}-${terraform.workspace}"
  
  # Common tags for all resources
  common_tags = {
    Environment = terraform.workspace
    Managed_by  = "terraform"
    Owner       = var.owner
    Project     = var.project_name
  }

  # Resource specific names
  ecs_cluster_name    = "${local.name_prefix}-ecs-cluster"
  ecs_service_name    = "${local.name_prefix}-ecs-service"
  ecr_repository_name = "${local.name_prefix}-ecr"
  lambda_function_name = "${local.name_prefix}-guardduty-lambda"
  task_family_name    = "${local.name_prefix}-task"
  task_name           = "${local.name_prefix}-task"
  container_name      = "${local.name_prefix}-container"
} 
