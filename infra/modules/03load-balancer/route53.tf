
# Create DNS Record for Portfolio Domain
resource "aws_route53_record" "portfolio_domain" {
  zone_id = data.aws_route53_zone.primary.zone_id
  name    = var.portfolio_domain_name
  type    = "A"

  alias {
    name                   = "dualstack.${aws_lb.alb.dns_name}"
    zone_id                = aws_lb.alb.zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_lb.alb]

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      zone_id
    ]
  }
}
