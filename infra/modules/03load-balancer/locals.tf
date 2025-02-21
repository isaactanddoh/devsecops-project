locals {
  # Naming convention for resources
  name_prefix = "isaac-${terraform.workspace}"
  
  # Common tags for all resources
  common_tags = {
    Environment = terraform.workspace
    Managed_by  = "terraform"
    Owner       = var.owner
    Project     = var.project_name
  }

  # Resource specific names
  alb_name              = "${local.name_prefix}-alb"
  target_group_name     = "${local.name_prefix}-tg"
  alb_logs_bucket_name  = "${local.name_prefix}-alb-logs"
} 