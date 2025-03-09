# Create OIDC Provider
resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = local.common_tags
}

# Create IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = local.github_actions_name
  
  assume_role_policy = templatefile("${path.module}/policies/assume-role-policy.json", {
    github_provider_arn = aws_iam_openid_connect_provider.github.arn
    owner              = var.owner
    infra_repo        = var.infra_repo
    app_repo        = var.app_repo
  })

  tags = merge(local.common_tags, {
    Name = local.github_actions_name
  })
}

# Create custom policy for Terraform
resource "aws_iam_policy" "terraform_policy" {
  name = "terraform-deployment-policy"

  policy = templatefile("${path.module}/policies/terraform-policy.json", {
    terraform_state_bucket_arn = aws_s3_bucket.terraform_state.arn
    region                     = var.aws_region
    account_id                 = data.aws_caller_identity.current.account_id
  })
}

# Attach required policies for Terraform
resource "aws_iam_role_policy_attachment" "terraform_permissions" {
  role       = aws_iam_role.github_actions.id
  policy_arn = aws_iam_policy.terraform_policy.arn
}

resource "aws_iam_role_policy" "github_actions" {
  name   = "github-actions-policy"
  role   = aws_iam_role.github_actions.id
  policy = file("${path.module}/policies/github-actions-policy.json")
} 