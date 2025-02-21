locals {
  # Naming convention for resources
  name_prefix = "isaac-${terraform.workspace}"

  ecs_cluster_name = "${local.name_prefix}-ecs-cluster"
  
  # Common tags for all resources
  common_tags = {
    Environment = terraform.workspace
    Managed_by  = "terraform"
    Owner       = var.owner
    Project     = var.project_name

  }
}
