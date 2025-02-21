# # Request an ACM Certificate for ALB
# resource "aws_acm_certificate" "acm_cert" {
#   domain_name       = "trial.thekloudwiz.com"
#   subject_alternative_names = ["sub.thekloudwiz.com"]
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = {
#     Name = "SSL-${var.domain_name}"
#   }
#   #checkov:skip=CKV2_AWS_71: "Ensure AWS ACM Certificate domain name does not include wildcards"
# }

# # Import an existing SSL/TLS certificate into ACM
# resource "aws_acm_certificate" "imported_cert" {
#   certificate_body = file("${path.root}/path-to-certificate-body/certificate.pem")
#   private_key = file("${path.root}/path-to-private-key/private.key")
#   certificate_chain = file("${path.root}/path-to-certificate-chain/ca_bundle.pem")

#   lifecycle {
#     create_before_destroy = true
#   }

#   tags = merge(local.common_tags, {
#     Name = "${local.name_prefix}-acm-cert"
#   })
# }

# # Create Route 53 DNS Record for SSL Validation
# resource "aws_route53_record" "cert_validation" {
#   for_each = {
#     for dvo in aws_acm_certificate.acm_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }

#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = data.aws_route53_zone.primary.zone_id
# }

# # Validate ACM Certificate
# resource "aws_acm_certificate_validation" "cert_validation" {
#   certificate_arn         = aws_acm_certificate.acm_cert.arn
#   validation_record_fqdns = [for record in aws_route53_record.cert_validation : record.fqdn]
# }

# resource "aws_iam_server_certificate" "ssl_cert" {
#   name        = "portfolio-thekloudwiz-com"
#   path        = "/cloudfront/"  # Recommended for IAM certificates
#   private_key = file("${path.root}/certs/private.key")
#   certificate_body = file("${path.root}/certs/certificate.pem")
#   certificate_chain = file("${path.root}/certs/ca_bundle.pem")

#   tags = merge(local.common_tags, {
#     Name = "portfolio-thekloudwiz-com"
#   })
# }
