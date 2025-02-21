# resource "aws_backup_plan" "backup_plan" {
#   name = "${local.name_prefix}-backup-plan"
#   rule {
#     rule_name = "${local.name_prefix}-backup-rule"
#     target_vault_name = aws_backup_vault.backup_vault.name
#     schedule = "cron(0 12 * * ? *)"
#     lifecycle {
#       delete_after = 30
#     }
#   }
# }   

# resource "aws_backup_vault" "backup_vault" {
#   name = "${local.name_prefix}-backup-vault"
# }

# resource "aws_backup_selection" "backup_selection" {
#   name         = "${local.name_prefix}-backup-selection"
#   plan_id      = aws_backup_plan.backup_plan.id
#   iam_role_arn = aws_iam_role.backup_role.arn

#   selection_tag {
#     type  = "STRINGEQUALS"
#     key   = "Environment"
#     value = var.environment
#   }

#   # Remove the ECS cluster ARN and add supported resources
#   resources = [
#     aws_ecr_repository.ecr_repo.arn,
#     # Add other supported resource ARNs here if needed
#     # Supported services include: EBS, EFS, RDS, DynamoDB, etc.
#   ]
# }