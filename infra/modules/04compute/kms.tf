# Create KMS Key for ECR
resource "aws_kms_key" "ecr_key" {
  description             = "KMS key for ${local.ecr_repository_name}"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  # Key policy
  policy = templatefile("${path.root}/policies/kms-policy.json", {
    account_id = data.aws_caller_identity.current.account_id
  })

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-ecr-key"
  })
}

# Create KMS Alias for ECR
resource "aws_kms_alias" "ecr_key_alias" {
  name          = "alias/${local.name_prefix}-ecr-key"
  target_key_id = aws_kms_key.ecr_key.key_id
}