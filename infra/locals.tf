locals {
  # Naming convention for resources
  name_prefix = "${var.project_name}-${terraform.workspace}"
  github_actions_name = "thekloudwiz-gha-role"


  # Enhanced common tags for all resources
  common_tags = {
    Environment  = terraform.workspace
    Managed_by   = "terraform"
    Owner        = var.owner
    Project      = var.project_name
    CostCenter   = var.cost_center
    BusinessUnit = "engineering"
    DataSensitivity = {
      dev     = "low"
      staging = "medium"
      prod    = "high"
    }[terraform.workspace]
    Backup = {
      dev     = "daily"
      staging = "daily"
      prod    = "hourly"
    }[terraform.workspace]
    MaintenanceWindow = {
      dev     = "any"
      staging = "weekends"
      prod    = "approved-window"
    }[terraform.workspace]
  }

  ecs_cluster_name = terraform.workspace == "prod" ? "${var.project_name}-prod" : "${var.project_name}-${terraform.workspace}"

  # Workspace specific configurations
  workspace_config = {
    dev = {
      instance_count        = 1
      instance_type         = "t3.micro"
      log_retention_days    = 7
      backup_retention_days = 7
      ecs_min_capacity      = 1
      ecs_max_capacity      = 2
      task_cpu              = 256
      task_memory           = 512
      container_user        = "1000:1000"
      api_rate_limit        = 2000
      memory_target_value   = 70
      cpu_target_value      = 70
      night_min_capacity    = 1
      night_max_capacity    = 2
      target_group_port     = 80
      waf_rule_thresholds = {
        request_limit = 2000
        ip_rate_limit = 2000
      }
    }
    staging = {
      instance_count        = 2
      instance_type         = "t3.small"
      log_retention_days    = 14
      backup_retention_days = 14
      ecs_min_capacity      = 2
      ecs_max_capacity      = 4
      task_cpu              = 512
      task_memory           = 1024
      container_user        = "1000:1000"
      api_rate_limit        = 5000
      memory_target_value   = 70
      cpu_target_value      = 70
      night_min_capacity    = 1
      night_max_capacity    = 2
      target_group_port     = 80
      waf_rule_thresholds = {
        request_limit = 5000
        ip_rate_limit = 5000
      }
    }
    prod = {
      instance_count        = 2
      instance_type         = "t3.medium"
      log_retention_days    = 30
      backup_retention_days = 30
      ecs_min_capacity      = 2
      ecs_max_capacity      = 5
      task_cpu              = 1024
      task_memory           = 2048
      container_user        = "1000:1000"
      memory_target_value   = 70
      cpu_target_value      = 70
      api_rate_limit        = 10000
      target_group_port     = 80
      waf_rule_thresholds = {
        request_limit = 10000
        ip_rate_limit = 10000
      }
      night_min_capacity = 1
      night_max_capacity = 2
    }
  }
} 