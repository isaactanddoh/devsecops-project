# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  name               = "${local.name_prefix}-s3-replication"
  assume_role_policy = file("${path.root}/policies/s3-assume-role-policy.json")

  tags = local.common_tags
}

# IAM policy for replication
resource "aws_iam_role_policy" "replication" {
  name = "${local.name_prefix}-s3-replication"
  role = aws_iam_role.replication.id
  policy = templatefile("${path.root}/policies/s3-replication-policy.json", {
    terraform_state_bucket_arn = aws_s3_bucket.terraform_state.arn,
    replica_bucket_arn         = aws_s3_bucket.terraform_state_replica.arn
  })
} 