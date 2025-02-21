package terraform

import input as tfplan

# Deny containers running as root
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    container := task_def.change.after.container_definitions[_]
    not container.user
    msg := sprintf("Container '%v' must not run as root", [container.name])
}

# Ensure proper tagging
deny contains msg if {
    resource := tfplan.resource_changes[_]
    
    # Only check resources that support tagging
    taggable_resources := {
        "aws_lb",
        "aws_ecs_cluster",
        "aws_ecs_service",
        "aws_ecs_task_definition",
        "aws_ecr_repository",
        "aws_s3_bucket",
        "aws_cloudwatch_log_group",
        "aws_sns_topic",
        "aws_cloudwatch_metric_alarm",
        "aws_wafv2_web_acl",
        "aws_wafv2_rule_group",
        "aws_wafv2_ip_set",
        "aws_lb_target_group"
    }
    
    # Skip data sources and non-taggable resources
    resource.mode == "managed"
    taggable_resources[resource.type]
    
    required_tags := {"Environment", "Project", "Owner"}
    resource_tags := {key | resource.change.after.tags[key]}
    missing := required_tags - resource_tags
    count(missing) > 0
    
    msg := sprintf("Resource '%v' of type '%v' is missing required tags: %v", [resource.address, resource.type, missing])
}

# Ensure container insights are enabled
deny contains msg if {
    cluster := tfplan.resource_changes[_]
    cluster.type == "aws_ecs_cluster"
    some i
    setting := cluster.change.after.setting[i]
    not setting.value == "enabled"
    msg := "Container Insights must be enabled on ECS cluster"
}

# Ensure ports are above 1024
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    container := task_def.change.after.container_definitions[_]
    port := container.portMappings[_].containerPort
    port <= 1024
    msg := sprintf("Container '%v' uses privileged port %v. Must be > 1024", [container.name, port])
}

# Ensure volumes are read-only
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    container := task_def.change.after.container_definitions[_]
    volume := container.mountPoints[_]
    not volume.readOnly
    msg := sprintf("Volume '%v' in container '%v' must be read-only", [volume.sourceVolume, container.name])
}