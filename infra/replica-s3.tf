# null resource to handle replication and object removal when destroying
resource "null_resource" "remove_replication" {
  triggers = {
    bucket_id = aws_s3_bucket.terraform_state_replica.id
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<EOF
    aws s3api delete-bucket-replication --bucket ${self.triggers.bucket_id}
    aws s3 rm s3://${self.triggers.bucket_id} --recursive
    EOF
  }
}

# Create replication bucket in secondary region
resource "aws_s3_bucket" "terraform_state_replica" {
  provider = aws.secondary
  bucket   = "${local.name_prefix}-replica-tfstate"
  force_destroy = true

  lifecycle {
    prevent_destroy = false
  }

  tags = local.common_tags

  #checkov:skip=CKV2_AWS_61: "Ensure that an S3 bucket has a lifecycle configuration"
  #checkov:skip=CKV_AWS_145: "Ensure that S3 buckets are encrypted with KMS by default"
  #checkov:skip=CKV_AWS_18: "Ensure the S3 bucket has access logging enabled"
  #checkov:skip=CKV2_AWS_62: "Ensure S3 buckets should have event notifications enabled"
}

# Enable versioning on replica bucket
resource "aws_s3_bucket_versioning" "terraform_state_replica" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.terraform_state_replica.id
  versioning_configuration {
    status = "Enabled"
  }
}

#ensure public access is blocked
resource "aws_s3_bucket_public_access_block" "terraform_state_replica" {
  provider = aws.secondary
  bucket   = aws_s3_bucket.terraform_state_replica.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}



