# AWS Region
variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "owner" {
  description = "Owner of the project"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "waf_scope" {
  description = "Scope of the WAF ACL"
  type        = string
}

# variable "alb_listener_port" {
#   description = "Port for ALB listener"
#   type        = number
# }

variable "alb_target_group_name" {
  description = "Target Group for ECS tasks"
  type        = string
}

variable "health_check_path" {
  description = "Health check path for ALB"
  type        = string
  default     = "/"
}

variable "alb_https_listener_port" {
  description = "HTTPS port for ALB listener"
  type        = number
}

# ALB Name
variable "alb_name" {
  description = "The name of the Application Load Balancer"
  type        = string
  default     = "secure-ci-cd-alb"
}

# ALB Security Group Name
variable "alb_security_group_name" {
  description = "Security group for ALB"
  type        = string
  default     = "secure-ci-cd-alb-sg"
}

# SSL Certificate ARN
variable "alb_certificate_arn" {
  description = "ARN of the SSL certificate for ALB"
  type        = string
}

# WAF ACL ID
variable "waf_acl_id" {
  description = "ID of the WAF ACL to associate with the ALB"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC"
  type        = string
}

variable "subnet_ids" {
  description = "List of subnet IDs"
  type        = list(string)
}

variable "alb_security_group_id" {
  description = "ID of the ALB security group"
  type        = string
}

variable "portfolio_domain_name" {
  description = "The portfolio domain name"
  type        = string
}

variable "container_port" {
  description = "Port on which the container is listening"
  type        = number
}
