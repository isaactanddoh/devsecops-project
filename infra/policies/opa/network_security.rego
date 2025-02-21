package terraform.network_security

import input as tfplan

# Ensure no public IP for production
deny contains msg if {
    service := tfplan.resource_changes[_]
    service.type == "aws_ecs_service"
    env := service.change.after.tags.Environment
    env == "prod"
    service.change.after.network_configuration[_].assign_public_ip == true
    msg := "Production ECS services must not have public IPs"
}

# Ensure proper security group rules
deny contains msg if {
    sg := tfplan.resource_changes[_]
    sg.type == "aws_security_group_rule"
    sg.change.after.cidr_blocks[_] == "0.0.0.0/0"
    sg.change.after.from_port == 0
    sg.change.after.to_port == 0
    msg := "Security group rule must not allow all traffic from 0.0.0.0/0"
}

# Ensure VPC flow logs are enabled
deny contains msg if {
    vpc := tfplan.resource_changes[_]
    vpc.type == "aws_vpc"
    not vpc.change.after.enable_flow_logs
    msg := "VPC flow logs must be enabled"
}

# Ensure load balancers use HTTPS and SSL certificates
deny contains msg if {
    lb := tfplan.resource_changes[_]
    lb.type == "aws_lb_listener"
    
    # Check if it's a frontend listener (port 80 or 443)
    lb.change.after.port in [80, 443]
    
    # Ensure HTTPS is used
    not lb.change.after.protocol == "HTTPS"
    
    msg := sprintf("%s: Load balancer listener must use HTTPS protocol", [lb.address])
}

deny contains msg if {
    lb := tfplan.resource_changes[_]
    lb.type == "aws_lb_listener"
    
    # For HTTPS listeners, ensure SSL certificate is configured
    lb.change.after.protocol == "HTTPS"
    not lb.change.after.certificate_arn
    
    msg := sprintf("%s: HTTPS listener must have a certificate configured", [lb.address])
}

# Ensure HTTP to HTTPS redirect is configured
deny contains msg if {
    lb := tfplan.resource_changes[_]
    lb.type == "aws_lb_listener"
    
    # Check if it's HTTP listener
    lb.change.after.protocol == "HTTP"
    
    # Ensure redirect to HTTPS is configured
    actions := [action.type | action := lb.change.after.default_action[_]]
    not "redirect" in actions
    
    msg := sprintf("%s: HTTP listener must redirect to HTTPS", [lb.address])
}

# Ensure proper SSL policy is used
deny contains msg if {
    lb := tfplan.resource_changes[_]
    lb.type == "aws_lb_listener"
    
    # For HTTPS listeners
    lb.change.after.protocol == "HTTPS"
    
    # List of approved SSL policies (adjust as needed)
    approved_policies := {
        "ELBSecurityPolicy-TLS-1-2-2017-01",
        "ELBSecurityPolicy-TLS-1-2-Ext-2018-06",
        "ELBSecurityPolicy-FS-1-2-2019-08",
        "ELBSecurityPolicy-TLS13-1-2-2021-06"
    }
    
    # Ensure an approved SSL policy is used
    not lb.change.after.ssl_policy in approved_policies
    
    msg := sprintf("%s: Must use an approved SSL policy. Allowed policies: %v", [lb.address, approved_policies])
}