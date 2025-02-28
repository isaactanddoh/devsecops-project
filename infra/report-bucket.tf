# # null resource to handle replication and objectremoval when destroying
# resource "null_resource" "remove_report_replication" {
#   triggers = {
#     bucket_id = aws_s3_bucket.security_reports.id
#   }

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOF
#     aws s3api delete-bucket-replication --bucket ${self.triggers.bucket_id}
#     aws s3 rm s3://${self.triggers.bucket_id} --recursive
#     EOF
#   }
# }

# KMS key for bucket encryption
resource "aws_kms_key" "report_bucket_key" {
  description             = "KMS key for security reports bucket encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Name        = "security-reports-kms-key"
    Environment = var.environment
    Project     = var.project_name
    Owner       = var.owner
  }

  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV2_AWS_64: "Ensure KMS key Policy is defined"
}

resource "aws_kms_alias" "report_bucket_key_alias" {
  name          = "alias/security-reports-key"
  target_key_id = aws_kms_key.report_bucket_key.key_id
}

# S3 Bucket for security reports
resource "aws_s3_bucket" "security_reports" {
  bucket = "${var.report_bucket_environment}-bucket-${var.timestamp}"

  tags = merge(local.common_tags, {
    Name = "security-reports-bucket"
    Managed_by = "terraform"
  })

  lifecycle {
    ignore_changes = [
      tags["Name"]
    ]
  }

  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
}

# Bucket versioning
resource "aws_s3_bucket_versioning" "reports_versioning" {
  bucket = aws_s3_bucket.security_reports.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Server-side encryption configuration
resource "aws_s3_bucket_server_side_encryption_configuration" "reports_encryption" {
  bucket = aws_s3_bucket.security_reports.id

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.report_bucket_key.arn
      sse_algorithm     = "aws:kms"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "reports_public_access_block" {
  bucket = aws_s3_bucket.security_reports.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket lifecycle policy
resource "aws_s3_bucket_lifecycle_configuration" "reports_lifecycle" {
  bucket = aws_s3_bucket.security_reports.id

  rule {
    id     = "reports_retention"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365 # Delete reports after 1 year
    }
  }

  #checkov:skip=CKV_AWS_300: "Ensure S3 lifecycle configuration sets period for aborting failed uploads"
}

# Bucket policy
resource "aws_s3_bucket_policy" "reports_bucket_policy" {
  bucket = aws_s3_bucket.security_reports.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceTLSRequestsOnly"
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          aws_s3_bucket.security_reports.arn,
          "${aws_s3_bucket.security_reports.arn}/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      },
      {
        Sid    = "AllowGitHubActionsAccess"
        Effect = "Allow"
        Principal = {
          AWS = [aws_iam_role.github_actions.arn]
        }
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.security_reports.arn,
          "${aws_s3_bucket.security_reports.arn}/*"
        ]
      }
    ]
  })
}