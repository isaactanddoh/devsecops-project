# Project Name
variable "project_name" {
  description = "Name of the project"
  type        = string
}

# IAM Certificate Name
variable "iam_cert_name" {
  description = "The name of the IAM certificate"
  type        = string
}

#Wildcard Domain Name
variable "wildcard_domain_name" {
  description = "The wildcard domain name"
  type        = string
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

# Owner of the resource
variable "owner" {
  description = "Owner of the resource"
  type        = string
}

# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

# VPC and Networking
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

# Subnet CIDR Blocks
variable "subnet_cidrs" {
  description = "List of CIDR blocks for subnets in multiple availability zones"
  type        = list(string)
}

# Availability Zones
variable "availability_zones_count" {
  description = "Number of AZs to use"
  type        = number
}

# Container Port
variable "container_port" {
  description = "Port that the container listens on"
  type        = number
}

# Health Check Path
variable "health_check_path" {
  description = "Health check path for ALB"
  type        = string
  default     = "/"
}

# ALB HTTPS Listener Port
variable "alb_https_listener_port" {
  description = "HTTPS port for ALB listener"
  type        = number
}

# Portfolio Domain Name
variable "portfolio_domain_name" {
  description = "The portfolio domain name"
  type        = string
}

#WAF
variable "waf_acl_name" {
  description = "AWS WAF WebACL Name"
  type        = string
  default     = "secure-waf-acl"
}

# WAF Scope
variable "waf_scope" {
  description = "Whether the WAF is for REGIONAL (ALB) or CLOUDFRONT"
  type        = string
  default     = "REGIONAL"
}

# WAF Default Action
variable "waf_default_action" {
  description = "Default action for WAF (allow or block)"
  type        = string
  default     = "ALLOW"
}

# Allowed CIDR Blocks
variable "allowed_cidr_blocks" {
  description = "List of allowed CIDR blocks for ALB access"
  type        = list(string)
  validation {
    condition     = length(var.allowed_cidr_blocks) > 0
    error_message = "At least one CIDR block must be specified"
  }
}

# GitHub OIDC Configuration
variable "github_org" {
  description = "GitHub organization name"
  type        = string
}

# GitHub Repository Name
variable "infra_repo" {
  description = "GitHub repository name"
  type        = string
}

variable "app_repo" {
  description = "GitHub repository name"
  type        = string
}

# Alert Email Address
variable "alert_email_address" {
  description = "Email address for infrastructure alerts"
  type        = string
}

# Security Alert Email Address
variable "security_alert_email_address" {
  description = "Email address for security alerts"
  type        = string
}

# Flow Logs Retention Days
variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs"
  type        = number
}

# Primary Domain Name
variable "primary_domain_name" {
  description = "The primary domain name"
  type        = string
}

# Cost Center
variable "cost_center" {
  description = "The cost center for the project"
  type        = string
}

# Container User
variable "container_user" {
  description = "The user for the container"
  type        = string
}

# Environment
variable "environment" {
  description = "The environment for the project"
  type        = string
  default     = "security-reports"
}

# environment for report bucket
variable "report_bucket_environment" {
  description = "The environment for the report bucket"
  type        = string
  default     = "security-reports"
}

# Timestamp
variable "timestamp" {
  description = "The timestamp for the project"
  type        = string
  default     = "220225"
}