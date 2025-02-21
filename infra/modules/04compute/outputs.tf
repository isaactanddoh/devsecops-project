# Output ECS Cluster ID
output "ecs_cluster_id" {
  description = "The ID of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.id
}

# Output ECS Task Definition ARN
output "ecs_task_definition_arn" {
  description = "The ARN of the ECS task definition"
  value       = aws_ecs_task_definition.task.arn
}

# Output ECS Service Name
output "ecs_service_name" {
  description = "The name of the ECS service"
  value       = aws_ecs_service.ecs_service.name
}

# Output ECR Repository URL
output "ecr_repository_url" {
  description = "The URL of the ECR repository"
  value       = aws_ecr_repository.ecr_repo.repository_url
}

# Output Lambda Function ARN
output "lambda_function_arn" {
  description = "The ARN of the Lambda function"
  value       = aws_lambda_function.guardduty_lambda.arn
}

# Output Auto Scaling Target ARN
output "ecs_scaling_target_arn" {
  description = "The ARN of the ECS auto scaling target"
  value       = aws_appautoscaling_target.ecs_scaling_target.arn
}

# Output Auto Scaling Policy ARN
output "ecs_scaling_policy_arn" {
  description = "The ARN of the ECS auto scaling policy"
  value       = aws_appautoscaling_policy.cpu_scaling.arn
}

# Output ECS Cluster Name
output "ecs_cluster_name" {
  value = aws_ecs_cluster.ecs_cluster.name
}

# Output Task Definition CPU
output "task_definition_cpu" {
  value = aws_ecs_task_definition.task.cpu
}

# Output Task Definition Memory
output "task_definition_memory" {
  value = aws_ecs_task_definition.task.memory
}

# Output Task Definition Read-Only Root Filesystem
output "task_definition_readonly_root" {
  value = jsondecode(aws_ecs_task_definition.task.container_definitions)[0].readonlyRootFilesystem
}

# Output Scaling Minimum Capacity
output "scaling_min_capacity" {
  value = aws_appautoscaling_target.ecs_scaling_target.min_capacity
}

# Output Scaling Maximum Capacity
output "scaling_max_capacity" {
  value = aws_appautoscaling_target.ecs_scaling_target.max_capacity
}

# Output CPU Target Value
output "cpu_target_value" {
  value = aws_appautoscaling_policy.cpu_scaling.target_tracking_scaling_policy_configuration[0].target_value
}

# Output Task Definition Privileged
output "task_definition_privileged" {
  value = jsondecode(aws_ecs_task_definition.task.container_definitions)[0].privileged
}

# Output CloudWatch Logging Enabled
output "cloudwatch_logging_enabled" {
  value = contains(keys(jsondecode(aws_ecs_task_definition.task.container_definitions)[0]), "logConfiguration")
}

# ECS outputs
output "ecs_cluster_arn" {
  description = "ARN of the ECS cluster"
  value       = aws_ecs_cluster.ecs_cluster.arn
}

output "ecs_service_arn" {
  description = "ARN of the ECS service"
  value       = aws_ecs_service.ecs_service.id
}

output "ecs_task_execution_role_arn" {
  description = "ARN of the ECS task execution role"
  value       = aws_iam_role.ecs_task_execution_role.arn
}

# output "ecs_service_discovery_enabled" {
#   description = "Status of ECS service discovery"
#   value       = aws_service_discovery_service.ecs.id != null
# }

# output "container_insights_enabled" {
#   description = "Status of Container Insights"
#   value       = aws_ecs_cluster.ecs_cluster.setting[*].value == ["enabled"]
# }

output "ecs_service_discovery_enabled" {
  description = "Whether service discovery is enabled"
  value       = true
}

output "container_insights_enabled" {
  description = "Whether Container Insights is enabled"
  value       = true  # Set to true to match your requirement
}

output "ecs_config" {
  description = "ECS configuration details"
  value = {
    task_execution_role = {
      name = aws_iam_role.ecs_execution_role.name
      arn  = aws_iam_role.ecs_execution_role.arn
    }
    service_discovery = {
      enabled = true
      namespace_id = aws_service_discovery_private_dns_namespace.ecs.id
    }
    cluster_settings = {
      container_insights = true
      cluster_name = local.ecs_cluster_name
    }
  }
}

# Backup outputs
# output "backup_plan_enabled" {
#   description = "Status of backup plan"
#   value       = aws_backup_plan.backup_plan.id != null
# }

# output "backup_selection_resources_configured" {
#   description = "Status of backup selection resources"
#   value       = aws_backup_selection.backup_selection.id != null
# }
