provider "aws" {
  region = var.aws_region

  default_tags {
    tags = local.common_tags
  }
}

provider "aws" {
  alias  = "secondary"
  region = "eu-central-1" # Frankfurt as backup region

  default_tags {
    tags = local.common_tags
  }
}

# # terraform backend
# terraform {
#   backend "s3" {
#     bucket         = "isaac-tfstate"
#     key            = "infra/terraform.tfstate"
#     region         = "eu-west-1"
#     encrypt        = true
#     use_lockfile   = true
#   }
# }