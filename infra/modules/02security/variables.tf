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


#WAF
variable "waf_acl_name" {
  description = "AWS WAF WebACL Name"
  type        = string
  default     = "secure-waf-acl"
}

#WAF Scope
variable "waf_scope" {
  description = "Whether the WAF is for REGIONAL (ALB) or CLOUDFRONT"
  type        = string
  default     = "REGIONAL"
}

#WAF Default Action
variable "waf_default_action" {
  description = "Default action for WAF (allow or block)"
  type        = string
  default     = "ALLOW"
}

# Workspace Config
variable "workspace_config" {
  description = "Configuration values for each workspace"
  type = map(object({
    waf_rule_thresholds = optional(object({
      request_limit = optional(number, 2000)
      ip_rate_limit = optional(number, 2000)
    }))
  }))
}

# Primary Domain Name
variable "primary_domain_name" {
  description = "The primary domain name"
  type        = string
}

#Portfolio Domain Name
variable "portfolio_domain_name" {
  description = "The portfolio domain name"
  type        = string
}

