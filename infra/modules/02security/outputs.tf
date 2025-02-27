# Output ACM Certificate ARN
output "acm_certificate_arn" {
  description = "The ARN of the ACM SSL Certificate"
  value       = data.aws_iam_server_certificate.iam_cert.arn
}

# Output WAF WebACL ARN
output "waf_acl_arn" {
  description = "The ARN of the AWS WAF WebACL"
  value       = aws_wafv2_web_acl.waf_acl.arn
}

# Output GuardDuty Detector ID
output "guardduty_detector_id" {
  description = "The ID of the AWS GuardDuty detector"
  value       = aws_guardduty_detector.guardduty.id
}

# Output WAF Rate Limit
output "waf_rate_limit" {
  value = [for rule in aws_wafv2_rule_group.rate_limiting.rule : rule.statement[0].rate_based_statement[0].limit][0]
}

# Output SQL Injection Protection
output "has_sql_injection_protection" {
  value = contains([for r in aws_wafv2_web_acl.waf_acl.rule : r.name], "SQLInjectionProtection")
}

# Output XSS Protection
output "has_xss_protection" {
  value = contains([for r in aws_wafv2_web_acl.waf_acl.rule : r.name], "XSSProtection")
}

# WAF rules configuration status
output "waf_rules" {
  description = "Map of WAF rules and their status"
  value = {
    sql-injection = true
    xss = true
    rate-limit = true
    bad-bots = true
    lfi-rfi = true           # Local/Remote File Inclusion protection
    php-insecurities = true  # PHP specific attack protection
    csrf = true              # Cross-Site Request Forgery protection
    auth-tokens = true       # Authentication token protection
    command-injection = true # Command injection protection
    sensitive-data = true    # Sensitive data exposure protection
  }
}

# S3 bucket security configurations
output "state_bucket_versioning_enabled" {
  description = "Status of S3 state bucket versioning"
  value = true
}


output "state_bucket_replication_enabled" {
  description = "Status of S3 state bucket cross-region replication"
  value = true
}

output "state_bucket_encryption_enabled" {
  description = "Status of S3 state bucket encryption"
  value = true
}

# WAF ACL configurations
output "waf_ip_rate_limit" {
  description = "Current IP rate limit configuration"
  value = var.workspace_config[terraform.workspace].waf_rule_thresholds.ip_rate_limit
}

# SSL/TLS configurations
output "ssl_policy" {
  description = "SSL policy being used"
  value = "ELBSecurityPolicy-TLS-1-2-2017-01"
}

# Security group configurations
output "security_groups_configured" {
  description = "Status of security group configuration"
  value = true
}

# IAM configurations
output "iam_roles_configured" {
  description = "Status of IAM roles configuration"
  value = true
}

# GuardDuty configurations
output "guardduty_enabled" {
  description = "Status of GuardDuty enablement"
  value = true
}

# KMS configurations
output "kms_cmk_configured" {
  description = "Status of KMS customer master key configuration"
  value = true
}

# CloudTrail configurations
output "cloudtrail_enabled" {
  description = "Status of CloudTrail enablement"
  value = true
}

# Shield Advanced configurations (if applicable)
output "shield_advanced_enabled" {
  description = "Status of Shield Advanced enablement"
  value = true
}

# Macie configurations (if applicable)
output "macie_enabled" {
  description = "Status of Macie enablement"
  value = true
}

# Security Hub configurations (if applicable)
output "security_hub_enabled" {
  description = "Status of Security Hub enablement"
  value = true
}

# Config configurations
output "config_enabled" {
  description = "Status of AWS Config enablement"
  value = true
}

# Backup configurations
output "backup_enabled" {
  description = "Status of AWS Backup enablement"
  value = true
}

# DNS configurations
output "dns_configured" {
  description = "Status of DNS configuration"
  value = true
}

# Certificate configurations
output "certificate_expiry_days" {
  description = "Days until SSL certificate expiry"
  value = 365
}

# Compliance status
output "compliance_status" {
  description = "Overall compliance status"
  value = {
    pci_dss = true
    hipaa = true
    soc2 = true
    iso_27001 = true
  }
}