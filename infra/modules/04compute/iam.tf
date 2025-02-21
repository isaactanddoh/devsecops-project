# ECS Task Execution Role Policy
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${local.name_prefix}-ecs-task-execution-role"
  assume_role_policy = file("${path.root}/policies/ecs-task-assume-role-policy.json")

  tags = local.common_tags
}

# ECS Task Execution Role Policy
resource "aws_iam_role_policy" "ecs_task_execution_role_policy" {
  name = "${local.name_prefix}-ecs-task-execution-role-policy"
  role = aws_iam_role.ecs_task_execution_role.id
  policy = file("${path.root}/policies/ecs-task-execution-role-policy.json")
}

# Add ECR pull permissions
resource "aws_iam_role_policy" "ecr_pull_policy" {
  name = "${local.name_prefix}-ecr-pull-policy"
  role = aws_iam_role.ecs_execution_role.id
  policy = file("${path.root}/policies/ecr-pull-policy.json")
} 

# Create ECS Task Role
resource "aws_iam_role" "ecs_task_role" {
  name = "${local.name_prefix}-task-role"

  assume_role_policy = file("${path.root}/policies/ecs-assume-role-policy.json")
}

# Create ECS Task Execution Role
resource "aws_iam_role" "ecs_execution_role" {
  name = "${local.name_prefix}-execution-role"

  assume_role_policy = file("${path.root}/policies/ecs-assume-role-policy.json")
}

# Add CloudWatch Logs policy to Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_cloudwatch" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
}

# Add ECS Task Execution Role policy
resource "aws_iam_role_policy_attachment" "ecs_task_execution" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = data.aws_iam_policy.ecs_task_execution_policy.arn
}

# Add SSM access for secrets if needed
resource "aws_iam_role_policy_attachment" "ecs_task_ssm" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = data.aws_iam_policy.ssm_read_only.arn
}

# Create IAM Role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "guardduty-lambda-role-${terraform.workspace}"
  assume_role_policy = file("${path.root}/policies/lambda-assume-role-policy.json")
}

# Create IAM Policy for Lambda
resource "aws_iam_policy" "lambda_policy" {
  name        = "GuardDutyLambdaPolicy"
  description = "Policy for Lambda to block IP in AWS WAF"

  policy = templatefile("${path.root}/policies/guardduty-lambda-policy.json", {
    sns_topic_arn = data.aws_ssm_parameter.sns_topic_arn.value
  })
}

# Attach IAM Policy to Lambda Role
resource "aws_iam_role_policy_attachment" "attach_lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_policy.arn
}

# Add VPC permissions to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_vpc_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = data.aws_iam_policy.lambda_vpc_policy.arn
}

# Create Lambda Permission for EventBridge
resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.guardduty_lambda.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.guardduty_event_rule.arn
}

resource "aws_iam_role" "backup_role" {
  name = "${local.name_prefix}-backup-role"
  assume_role_policy = file("${path.root}/policies/backup-assume-role-policy.json")
}

resource "aws_iam_role_policy_attachment" "backup_policy_attachment" {
  role = aws_iam_role.backup_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
}