variable "alert_email_address" {
  description = "Email address to receive alerts"
  type        = string
}

variable "flow_logs_retention_days" {
  description = "Number of days to retain VPC Flow Logs"
  type        = number
}

variable "api_latency_threshold" {
  description = "Threshold for API latency"
  type        = number
  default     = 1
}

variable "owner" {
  description = "Owner of the project"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

# variable "ecs_cluster_name" {
#   description = "Name of the ECS cluster"
#   type        = string
# }

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

variable "cpu_threshold" {
  description = "CPU utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "memory_threshold" {
  description = "Memory utilization threshold for alarm"
  type        = number
  default     = 80
}

variable "alb_arn_suffix" {
  description = "ARN suffix of the ALB"
  type        = string
}
