# Create S3 bucket for ALB logs
resource "aws_s3_bucket" "alb_logs" {
  bucket = local.alb_logs_bucket_name
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = local.alb_logs_bucket_name
  })

  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
}

# Block public access
resource "aws_s3_bucket_public_access_block" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable Access Logging on ALB logs
resource "aws_s3_bucket_logging" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  target_bucket = aws_s3_bucket.alb_logs.id
  target_prefix = "logs/"
}

# Create S3 bucket policy for ALB logs
resource "aws_s3_bucket_policy" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_elb_service_account.main.id}:root"
        }
        Action = "s3:PutObject"
        Resource = "${aws_s3_bucket.alb_logs.arn}/*"
      }
    ]
  })
}

# Enable versioning on ALB logs
resource "aws_s3_bucket_versioning" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Enable event notification on ALB logs
resource "aws_s3_bucket_notification" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  eventbridge = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_logs" {
  bucket = aws_s3_bucket.alb_logs.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Target Group
resource "aws_lb_target_group" "ecs_target_group" {
  name        = local.target_group_name
  port        = var.container_port
  protocol    = "HTTP"
  vpc_id      = data.aws_ssm_parameter.vpc_id.value
  target_type = "ip"

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = merge(local.common_tags, {
    Name = local.target_group_name
  })

  #checkov:skip=CKV_AWS_378: "Ensure AWS Load Balancer doesn't use HTTP protocol"
}

# Create the ALB
resource "aws_lb" "alb" {
  name               = local.alb_name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [data.aws_ssm_parameter.alb_sg_id.value]
  subnets           = split(",", data.aws_ssm_parameter.public_subnet_ids.value)

  # Ensure that ALB drops HTTP headers
  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = terraform.workspace
    enabled = true
  }

  enable_deletion_protection = terraform.workspace == "prod" ? true : false

  tags = merge(local.common_tags, {
    Name = local.alb_name
  })
  #checkov:skip=CKV_AWS_150: "Ensure that Load Balancer has deletion protection enabled"
  #checkov:skip=CKV_AWS_131: "Ensure that ALB drops HTTP headers"
  #checkov:skip=CKV2_AWS_20: "Ensure that ALB redirects HTTP requests into HTTPS ones"
}

# HTTP to HTTPS redirect
resource "aws_lb_listener" "http_redirect" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn

    redirect {
      protocol    = "HTTPS"
      port        = var.container_port
      status_code = "HTTP_301"
    }
  }
}

# HTTPS Listener (Handles Secure Traffic)
resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = var.alb_https_listener_port
  protocol         = "HTTPS"
  ssl_policy       = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn  = data.aws_iam_server_certificate.iam_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_target_group.arn
  }
}

# Associate WAF with ALB
resource "aws_wafv2_web_acl_association" "waf_alb_association" {
  resource_arn = aws_ssm_parameter.alb_arn.value
  web_acl_arn  = data.aws_ssm_parameter.waf_acl_arn.value
}

