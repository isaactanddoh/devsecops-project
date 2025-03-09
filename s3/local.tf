locals {
  bucket_name = "${var.project_name}-tfstate-01032025"

  github_actions_name = "thekloudwiz-gha-role"

  common_tags = {
    Project     = var.project_name
    Owner       = var.owner
    ManagedBy   = "Terraform"
  }
}

variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "project_name" {
  type    = string
  default = "devsecops"
}

variable "owner" {
  type    = string
  default = "isaactanddoh"
}

variable "infra_repo" {
  type    = string
  default = "devsecops-project"
}

variable "app_repo" {
  type    = string
  default = "portfolio-app"
}

variable "report_bucket_environment" {
  description = "The environment for the report bucket"
  type        = string
  default     = "security-reports"
}

variable "timestamp" {
  description = "The timestamp for the project"
  type        = string
  default     = "220225"
}

data "aws_caller_identity" "current" {}
