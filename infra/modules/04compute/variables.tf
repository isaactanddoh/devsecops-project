# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

# ECS Cluster Name
variable "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  type        = string
  default     = "secure-ci-cd-cluster"
}

# ECS Task CPU
variable "task_cpu" {
  description = "The amount of CPU to allocate for the ECS task"
  type        = number
  default     = 256
}

# ECS Task Memory
variable "task_memory" {
  description = "The amount of memory to allocate for the ECS task"
  type        = number
  default     = 512
}


variable "memory_threshold" {
  description = "Memory utilization threshold for alarm"
  type        = number
  default     = 80
}

# Container & Port Configuration
variable "container_port" {
  description = "The container port the application listens on"
  type        = number
  default     = 3000
}

# ECR Repository Name
variable "ecr_repository_name" {
  description = "The name of the ECR repository"
  type        = string
  default     = "secure-ci-cd-app"
}

# Lambda Function Name
variable "lambda_function_name" {
  description = "Name of the Lambda function for GuardDuty automation"
  type        = string
  default     = "GuardDutyResponseLambda"
}

# IAM Role for Lambda
variable "lambda_role_name" {
  description = "Name of the IAM role for Lambda function"
  type        = string
  default     = "GuardDutyLambdaRole"
}

# Auto Scaling Configuration
variable "ecs_min_capacity" {
  description = "Minimum number of ECS tasks"
  type        = number
  default     = 2
}

# Auto Scaling Maximum Capacity
variable "ecs_max_capacity" {
  description = "Maximum number of ECS tasks"
  type        = number
  default     = 5
}

# CPU Target Value
variable "cpu_target_value" {
  description = "Target CPU utilization percentage for auto scaling"
  type        = number
  default     = 50
}

# Environment Name
variable "environment" {
  description = "Environment name"
  type        = string
}

# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Owner of the resource
variable "owner" {
  description = "Owner of the resource"
  type        = string
}

# Add WAF ACL ID variable
variable "waf_acl_id" {
  description = "ID of the WAF ACL for Lambda to update"
  type        = string
}

# Workspace Config
variable "workspace_config" {
  description = "Configuration values for each workspace"
  type = object({
    instance_count        = number
    instance_type         = string
    log_retention_days    = number
    backup_retention_days = number
    ecs_min_capacity      = number
    ecs_max_capacity      = number
    task_cpu              = number
    task_memory           = number
    memory_target_value   = number
    cpu_target_value      = number
    night_min_capacity    = number
    night_max_capacity    = number
    container_user        = string
  })
}


# VPC ID
variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

# Subnet IDs
variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

# ECS Security Group ID
variable "ecs_security_group_id" {
  description = "ID of the ECS security group"
  type        = string
}

# App Version
variable "app_version" {
  description = "The version of the application"
  type        = string
  default     = "1.0.0"
}

# Container User
variable "container_user" {
  description = "The user to run the container as (for security)"
  type        = string
  default     = "1000:1000"  # Default to non-root user
}

