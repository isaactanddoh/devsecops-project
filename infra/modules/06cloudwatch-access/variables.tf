# AWS Region
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
}

# Dashboard Name
variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = "secure-ci-cd-dashboard"
}

# Enable SSO
variable "enable_sso" {
  description = "Enable AWS SSO for CloudWatch access"
  type        = bool
  default     = true
}

# SSO Instance ARN
variable "sso_instance_arn" {
  description = "ARN of the AWS SSO instance"
  type        = string
  default     = ""
}

# Team Member Names
variable "team_member_names" {
  description = "List of team member names for CloudWatch access"
  type        = list(string)
  default     = ["sre-engineer", "devops-engineer", "cloud-engineer"]
}

# Environment
variable "environment" {
  description = "Environment name"
  type        = string
}

# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# Owner
variable "owner" {
  description = "Owner of the resource"
  type        = string
}

variable "policy_name" {
  description = "IAM Policy name"
  type        = string
  default     = "CloudWatchDashboardReadOnly"
}

variable "group_name" {
  description = "IAM Group name"
  type        = string
  default     = "cloudwatch-dashboard-users"
}