# Get Route 53 Hosted Zone
data "aws_route53_zone" "primary" {
  name       = var.primary_domain_name
  private_zone = false
}

# Get IAM Certificate
data "aws_iam_server_certificate" "iam_cert" {
  name = "portfolio-thekloudwiz-com"
}


