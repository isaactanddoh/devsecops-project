locals {
  # Naming convention for resources
  name_prefix = "${var.project_name}-${terraform.workspace}"
  
  # Common tags for all resources
  common_tags = {
    Environment     = terraform.workspace
    Managed_by     = "terraform"
    Owner          = var.owner
    Project        = var.project_name
    DataSensitivity = {
      dev     = "low"
      staging = "medium"
      prod    = "high"
    }[var.environment]
    Backup = {
      dev     = "daily"
      staging = "daily"
      prod    = "hourly"
    }[var.environment]
    MaintenanceWindow = {
      dev     = "any"
      staging = "weekends"
      prod    = "approved-window"
    }[var.environment]
  }

  workspace_config = {
    dev = {
      log_retention_days = 30
    }
    staging = {
      log_retention_days = 30
    }
    prod = {
      log_retention_days = 90
    }
  }


  # Resource specific names
  dashboard_name = "${local.name_prefix}-security-performance"
  role_name     = "${local.name_prefix}-cloudwatch-access-role"
  policy_name   = "${local.name_prefix}-cloudwatch-access-policy"
  group_name    = "${local.name_prefix}-cloudwatch-users"

  # Environment specific configurations
  retention_days = lookup(local.workspace_config[terraform.workspace], "log_retention_days", 30)
  
  # Access configurations
  cloudwatch_permissions = {
    dev = [
      "cloudwatch:GetDashboard",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListDashboards"
    ]
    staging = [
      "cloudwatch:GetDashboard",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListDashboards",
      "cloudwatch:GetMetricStatistics"
    ]
    prod = [
      "cloudwatch:GetDashboard",
      "cloudwatch:GetMetricData",
      "cloudwatch:ListDashboards",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:DescribeAlarms"
    ]
  }
} 