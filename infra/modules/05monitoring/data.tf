# Temporarily removed during destroy
data "aws_dynamodb_table" "terraform_locks" {
  name = "isaac-${terraform.workspace}-terraform-locks"
}

# data "aws_s3_bucket" "terraform_state" {
#   bucket = "isaac-tfstate"
# }


data "aws_ssm_parameter" "vpc_id" {
  name = "/isaac-${terraform.workspace}/vpc_id"
}

data "aws_lb" "alb" {
  name = "${local.name_prefix}-alb"
}