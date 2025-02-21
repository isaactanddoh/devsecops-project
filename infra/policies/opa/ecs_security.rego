package terraform.ecs_security

import input as tfplan

# Ensure ECS services are using FARGATE
deny contains msg if {
    service := tfplan.resource_changes[_]
    service.type == "aws_ecs_service"
    not service.change.after.launch_type == "FARGATE"
    msg := "ECS services must use FARGATE launch type"
}

# Ensure minimum healthy percent is set
deny contains msg if {
    service := tfplan.resource_changes[_]
    service.type == "aws_ecs_service"
    service.change.after.deployment_minimum_healthy_percent < 50
    msg := "ECS service minimum healthy percent must be at least 50%"
}

# Ensure proper service discovery
deny contains msg if {
    service := tfplan.resource_changes[_]
    service.type == "aws_ecs_service"
    not service.change.after.service_registries
    msg := "ECS service must use service discovery"
}