# Common variables for all tests
variables {
  aws_region = "eu-west-1"
  vpc_cidr = "10.0.0.0/16"
  subnet_cidrs = ["10.0.1.0/24", "10.0.2.0/24"]
  allowed_cidr_blocks = ["10.0.0.0/8"]
  availability_zones_count = 2
  container_port = 3000
  portfolio_domain_name = "test.thekloudwiz.com"
  primary_domain_name = "thekloudwiz.com"
  alert_email_address = "test@example.com"
  flow_logs_retention_days = 14
  alb_https_listener_port = 443
}

# Test environment-specific configurations
run "verify_dev_environment" {
  command = plan

  variables {
    environment = "dev"
  }

  assert {
    condition = local.workspace_config["dev"].instance_count == 1
    error_message = "Dev environment should have 1 instance"
  }

  assert {
    condition = local.workspace_config["dev"].task_cpu == 256
    error_message = "Dev environment should have 256 CPU units"
  }

  assert {
    condition = local.workspace_config["dev"].task_memory == 512
    error_message = "Dev environment should have 512MB memory"
  }
}

run "verify_staging_environment" {
  command = plan

  variables {
    environment = "staging"
  }

  assert {
    condition = local.workspace_config["staging"].instance_count == 2
    error_message = "Staging environment should have 2 instances"
  }

  assert {
    condition = local.workspace_config["staging"].log_retention_days >= 14
    error_message = "Staging environment should retain logs for at least 14 days"
  }

  assert {
    condition = local.workspace_config["staging"].backup_retention_days >= 14
    error_message = "Staging environment should retain backups for at least 14 days"
  }
}

run "verify_prod_environment" {
  command = plan

  variables {
    environment = "prod"
  }

  assert {
    condition = local.workspace_config["prod"].instance_count >= 2
    error_message = "Production environment should have at least 2 instances"
  }

  assert {
    condition = local.workspace_config["prod"].log_retention_days >= 30
    error_message = "Production environment should retain logs for at least 30 days"
  }

  assert {
    condition = local.workspace_config["prod"].backup_retention_days >= 30
    error_message = "Production environment should retain backups for at least 30 days"
  }
}

# Test WAF OWASP Top 10 protections
run "verify_waf_security" {
  command = plan

  assert {
    condition = contains(keys(module.security.waf_rules), "sql-injection")
    error_message = "WAF must include SQL injection protection"
  }

  assert {
    condition = contains(keys(module.security.waf_rules), "xss")
    error_message = "WAF must include XSS protection"
  }

  assert {
    condition = contains(keys(module.security.waf_rules), "rate-limit")
    error_message = "WAF must include rate limiting"
  }

  assert {
    condition = contains(keys(module.security.waf_rules), "bad-bots")
    error_message = "WAF must include bad bot protection"
  }
}

# Test S3 bucket configurations
run "verify_s3_configurations" {
  command = plan

  assert {
    condition = module.security.state_bucket_versioning_enabled
    error_message = "S3 state bucket must have versioning enabled"
  }

  assert {
    condition = module.security.state_bucket_replication_enabled
    error_message = "S3 state bucket must have replication enabled"
  }

  assert {
    condition = module.security.state_bucket_encryption_enabled
    error_message = "S3 state bucket must have encryption enabled"
  }
}

# Test monitoring and alerting
run "verify_monitoring_configuration" {
  command = plan

  assert {
    condition     = can(module.monitoring.alarms_configured)
    error_message = "CloudWatch alarms must be configured"
  }

  assert {
    condition = alltrue([
      # Check if SNS topic is being created
      try(module.monitoring.sns_topic_name != "", true)
    ])
    error_message = "SNS topic is not configured correctly"
  }

  assert {
    condition     = can(module.monitoring.log_groups_configured)
    error_message = "Log groups must be configured"
  }

  # Verify flow logs basic configuration
  # assert {
  #   condition = can(module.monitoring.flow_logs_config) && length(keys(module.monitoring.flow_logs_config)) == 3
  #   error_message = "Flow logs configuration structure should be properly defined"
  # }

  # Verify log group name pattern
  # assert {
  #   condition = can(regex("^/aws/vpc/flow-logs/", 
  #                 try(module.monitoring.flow_logs_config.log_group_name, "")))
  #   error_message = "Flow logs log group name should follow the correct pattern"
  # }

  # Verify retention days configuration
  assert {
    condition = try(module.monitoring.flow_logs_config.retention_days, 0) > 0
    error_message = "Flow logs retention period should be greater than 0 days"
  }
}

# Test network security
run "verify_network_security" {
  command = plan

  # assert {
  #   condition = module.security.network_acls_configured
  #   error_message = "Network ACLs must be configured"
  # }

  assert {
    condition = length(module.networking.public_subnet_ids) >= 2
    error_message = "Must have at least 2 subnets for high availability"
  }

  assert {
    condition = length(module.networking.private_subnet_ids) >= 2
    error_message = "Must have at least 2 subnets for high availability"
  }
}

# Test ECS configurations
run "verify_ecs_configuration" {
  command = plan


  # Validate task execution role name pattern
  assert {
    condition = can(module.compute.ecs_config.task_execution_role.name)
    error_message = "Task execution role name should be defined"
  }

  # Verify service discovery configuration
  # Validate service discovery configuration structure
  assert {
    condition = can(module.compute.ecs_config.service_discovery.enabled)
    error_message = "Service discovery configuration should be defined"
  }

  # Verify container insights
  assert {
    condition = try(module.compute.ecs_config.cluster_settings.container_insights == true, false)
    error_message = "Container insights must be enabled"
  }

    # Validate cluster settings
  assert {
    condition = can(module.compute.ecs_config.cluster_settings.container_insights)
    error_message = "Cluster settings should be defined with container insights configuration"
  }
}


# # Test backup configurations
# run "verify_backup_configuration" {
#   command = plan

#   assert {
#     condition = module.compute.backup_plan_enabled
#     error_message = "Backup plan must be enabled"
#   }

#   assert {
#     condition = module.compute.backup_selection_resources_configured
#     error_message = "Backup selection resources must be configured"
#   }
# }

# Test load balancer configurations
run "verify_load_balancer_configuration" {
  command = plan

  assert {
    condition = module.load_balancer.access_logs_enabled
    error_message = "ALB access logs must be enabled"
  }

  assert {
    condition = module.load_balancer.ssl_policy == "ELBSecurityPolicy-TLS13-1-2-2021-06"
    error_message = "ALB must use modern TLS policy (TLS 1.3)"
  }

  # Environment-specific deletion protection check
  assert {
    condition = (
      terraform.workspace == "prod" ? module.load_balancer.deletion_protection_enabled : true
    )
    error_message = "ALB deletion protection must be enabled in production environment"
  }
}
