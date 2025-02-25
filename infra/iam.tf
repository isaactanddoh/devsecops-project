# IAM role for S3 replication
resource "aws_iam_role" "replication" {
  name               = "${local.name_prefix}-s3-replication"
  assume_role_policy = file("${path.root}/policies/s3-assume-role-policy.json")

  tags = local.common_tags
}