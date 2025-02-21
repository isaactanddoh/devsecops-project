# Create AWS WAF WebACL
resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "${local.name_prefix}-waf"
  scope       = var.waf_scope
  description = "WAF to protect against SQL Injection, XSS, and bad requests"

  default_action {
    dynamic "allow" {
      for_each = var.waf_default_action == "ALLOW" ? [1] : []
      content {}
    }
    
    dynamic "block" {
      for_each = var.waf_default_action == "BLOCK" ? [1] : []
      content {}
    }
  }

  # SQL Injection Protection Rule
  rule {
    name     = "SQLInjectionProtection"
    priority = 1

    action {
      block {}
    }

    statement {
      sqli_match_statement {
        field_to_match {
          all_query_arguments {}
        }
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
      
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "SQLInjectionProtection"
      sampled_requests_enabled   = true
    }
  }

  # XSS (Cross-Site Scripting) Protection Rule
  rule {
    name     = "XSSProtection"
    priority = 2

    action {
      block {}
    }

    statement {
      xss_match_statement {
        field_to_match {
          all_query_arguments {}
        }
        text_transformation {
          priority = 3
          type     = "HTML_ENTITY_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "XSSProtection"
      sampled_requests_enabled   = true
    }
  }

  # Bad Bots Protection Rule
  rule {
    name     = "BadBots"
    priority = 4

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        search_string         = "bot"
        text_transformation {
          priority = 1
          type     = "LOWERCASE"
        }
      }
    #checkov:skip=CKV_AWS_192: "Ensure WAF prevents message lookup in Log4j2. See CVE-2021-44228 aka log4jshell"
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "BadBots"
      sampled_requests_enabled   = true
    }
  }

  # Max Request Size Protection Rule
  rule {
    name     = "MaxRequestSize"
    priority = 5

    action {
      block {}
    }

    statement {
      size_constraint_statement {
        comparison_operator = "GT"
        size               = 10485760  # 10MB
        field_to_match {
          body {}
        }
        text_transformation {
          priority = 1
          type     = "NONE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "MaxRequestSize"
      sampled_requests_enabled   = true
    }
  }

  rule {
  name     = "Log4jProtection"
  priority = 6

  action {
    block {}
  }

  statement {
    byte_match_statement {
      field_to_match {
        all_query_arguments {}
      }
      positional_constraint = "CONTAINS"
      search_string         = "jndi:"
      text_transformation {
        priority = 1
        type     = "NONE"
      }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "Log4jProtection"
    sampled_requests_enabled   = true
  }
}

  # Add geo-restriction rule for prod
  dynamic "rule" {
    for_each = terraform.workspace == "prod" ? [1] : []
    content {
      name     = "GeoRestriction"
      priority = 7

      action {
        block {}
      }

      statement {
        geo_match_statement {
          country_codes = ["RU", "CN", "NK", "IR"]  # Block high-risk countries
        }
      }

      visibility_config {
        cloudwatch_metrics_enabled = true
        metric_name                = "GeoRestriction"
        sampled_requests_enabled   = true
      }
    }
  }

  # Add OWASP Top 10 Protection Rules
  rule {
    name     = "PathTraversal"
    priority = 8

    action {
      block {}
    }

    statement {
      byte_match_statement {
        field_to_match {
          uri_path {}
        }
        positional_constraint = "CONTAINS"
        search_string         = "../"
        text_transformation {
          priority = 1
          type     = "URL_DECODE"
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "PathTraversal"
      sampled_requests_enabled   = true
    }
  }

  # Rate limiting for specific endpoints
  rule {
    name     = "APIRateLimit"
    priority = 9

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = lookup(var.workspace_config[terraform.workspace], "api_rate_limit", 2000)
        aggregate_key_type = "IP"
        
        scope_down_statement {
          byte_match_statement {
            field_to_match {
              uri_path {}
            }
            positional_constraint = "STARTS_WITH"
            search_string         = "/api/"
            text_transformation {
              priority = 1
              type     = "NONE"
            }
          }
        }
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "APIRateLimit"
      sampled_requests_enabled   = true
    }
  }

  # IP Reputation List
  rule {
    name     = "IPReputationList"
    priority = 10

    action {
      block {}
    }

    statement {
      ip_set_reference_statement {
        arn = aws_wafv2_ip_set.malicious_ips.arn
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPReputationList"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${local.name_prefix}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-waf"
  })
  
  #checkov:skip=CKV2_AWS_31: "Ensure WAF2 has a Logging Configuration"
}

# Add rate limiting based on workspace configuration
resource "aws_wafv2_rule_group" "rate_limiting" {
  name     = "${local.name_prefix}-rate-limiting"
  scope    = var.waf_scope
  capacity = 50

  rule {
    name     = "ip-rate-limit"
    priority = 1

    action {
      block {}
    }

    statement {
      rate_based_statement {
        limit              = var.workspace_config[terraform.workspace].waf_rule_thresholds.ip_rate_limit
        aggregate_key_type = "IP"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "IPRateLimit"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name               = "${local.name_prefix}-rate-limiting"
    sampled_requests_enabled  = true
  }

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-rate-limiting"
  })
}

# Create IP set for malicious IPs
resource "aws_wafv2_ip_set" "malicious_ips" {
  name               = "${local.name_prefix}-malicious-ips"
  description        = "IP set for known malicious IPs"
  scope             = var.waf_scope
  ip_address_version = "IPV4"
  addresses         = []  # Empty by default, will be updated by GuardDuty Lambda

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-malicious-ips"
  })
}