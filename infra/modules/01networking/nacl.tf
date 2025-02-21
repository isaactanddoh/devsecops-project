# resource "aws_network_acl_rule" "private" {
#   network_acl_id = aws_ssm_parameter.private_nacl_id.value
#   rule_number    = 100
#   egress         = false
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 65535
# }

# resource "aws_network_acl_rule" "private_egress" {
#   network_acl_id = aws_ssm_parameter.private_nacl_id.value
#   rule_number    = 100
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
#   cidr_block     = "0.0.0.0/0"
#   from_port      = 0
#   to_port        = 65535
# }

# resource "aws_network_acl_rule" "private_egress_all" {
#   network_acl_id = aws_ssm_parameter.private_nacl_id.value
#   rule_number    = 100
#   egress         = true
#   protocol       = "tcp"
#   rule_action    = "allow"
# }