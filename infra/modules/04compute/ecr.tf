# Create ECR Repository
resource "aws_ecr_repository" "ecr_repo" {
  name = local.ecr_repository_name
  force_delete = true

  # Ensure image tags are immutable
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key        = aws_kms_key.ecr_key.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = merge(local.common_tags, {
    Name = local.ecr_repository_name
  })
}

# ECR lifecycle policy
resource "aws_ecr_lifecycle_policy" "repo_policy" {
  repository = aws_ecr_repository.ecr_repo.name

  policy = file("${path.root}/policies/ecr-lifecycle-policy.json")
}
