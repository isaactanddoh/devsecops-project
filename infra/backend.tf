# S3 bucket for Terraform state
resource "aws_s3_bucket" "terraform_state" {
  bucket        = "${local.bucket_name}"
  force_destroy = true

  # Prevent/Allow accidental deletion
  lifecycle {
    prevent_destroy = false
  }

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 buckets are version enabled"
  #checkov:skip=CKV_AWS_21: "Ensure all data stored in the S3 bucket have versioning enabled"
}

#  Enable Access Logging
resource "aws_s3_bucket_logging" "terraform_state" {
  bucket        = aws_s3_bucket.terraform_state.id
  target_bucket = aws_s3_bucket.terraform_state.id
  target_prefix = "logs/"
}

#Enable event notification
resource "aws_s3_bucket_notification" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  eventbridge = true
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Block public access
resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Add lifecycle rules
resource "aws_s3_bucket_lifecycle_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    id     = "state-backup"
    status = "Enabled"

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    noncurrent_version_transition {
      noncurrent_days = 7
      storage_class   = "GLACIER"
    }

    expiration {
      expired_object_delete_marker = true
    }

    abort_incomplete_multipart_upload {
      days_after_initiation = 7
    }
  }
}
