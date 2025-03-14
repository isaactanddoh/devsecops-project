locals {
  # Naming convention for resources
  name_prefix = "${var.project_name}-${terraform.workspace}"
  
  # Common tags for all resources
  common_tags = {
    Environment = terraform.workspace
    Managed_by  = "terraform"
    Owner       = "isaac"
    Project     = "${var.project_name}"
  }

  # Resource specific names
  vpc_name         = "${local.name_prefix}-vpc"
  igw_name         = "${local.name_prefix}-igw"
  public_subnet_name      = "${local.name_prefix}-public-subnet"
  private_subnet_name      = "${local.name_prefix}-private-subnet"
  alb_sg_name      = "${local.name_prefix}-alb-sg"
  ecs_sg_name      = "${local.name_prefix}-ecs-sg"
} 