# null resource to handle replication and objectremoval when destroying
resource "null_resource" "lambda_bucket_remove_replication" {
  triggers = {
    bucket_id = aws_s3_bucket.lambda_bucket.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    aws s3api delete-bucket-replication --bucket ${self.triggers.bucket_id}
    aws s3 rm s3://${self.triggers.bucket_id} --recursive
    EOF
  }
}

#create a bucket for lambda
resource "aws_s3_bucket" "lambda_bucket" {
  bucket = "${local.name_prefix}-lambda-bucket"
  force_destroy = true

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-lambda-bucket"
  })

  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_144: "Ensure that S3 bucket has cross-region replication enabled"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
}

# #enable private access
# resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
#   bucket = aws_s3_bucket.lambda_bucket.id
#   acl    = "private"
# }

#enable versioning
resource "aws_s3_bucket_versioning" "lambda_bucket_versioning" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "lambda_bucket_encryption" {
  bucket = aws_s3_bucket.lambda_bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# block public access
resource "aws_s3_bucket_public_access_block" "lambda_bucket_public_access_block" {
  bucket = aws_s3_bucket.lambda_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


#create a zip file for lambda
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  key    = "lambda-function.zip"
  source = "${path.module}/lambda_function.zip"
  
  lifecycle {
    ignore_changes = [etag, source, source_hash]
  }
}