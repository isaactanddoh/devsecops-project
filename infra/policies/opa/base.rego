package terraform

import input as tfplan

########################
# Parameters for Rules
########################

# Valid AWS regions
allowed_regions := ["eu-west-1", "eu-central-1"]

# Allowed instance types by environment
allowed_instance_types := {
    "dev": ["t3.micro", "t3.small"],
    "staging": ["t3.small", "t3.medium"],
    "prod": ["t3.medium", "t3.large", "t3.xlarge"]
}

# Required tags
required_tags := ["Environment", "Owner", "Project", "Managed_by"]

# Taggable resources
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

#################
# Helper Functions
#################

# Get the last action in the changes
last_action(resource) = action {
    actions := resource.change.actions
    action := actions[count(actions) - 1]
}

# Check if a resource is being deleted
is_delete(resource) {
    last_action(resource) == "delete"
}

# Check if a resource has all required tags
has_all_required_tags(tags) {
    missing := required_tags - {x | x := object.keys(tags)[_]}
    count(missing) == 0
}

# Check if instance type is allowed for environment
is_allowed_instance_type(type, env) {
    allowed_instance_types[env][_] == type
}

#################
# Deny Rules
#################

# Missing required tags
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == taggable_resources[_]
    
    not has_all_required_tags(resource.change.after.tags)
    
    msg := sprintf(
        "resource %v missing required tags. tags present: %v",
        [resource.address, object.keys(resource.change.after.tags)]
    )
}

# Invalid instance types
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_instance"
    
    env := resource.change.after.tags.Environment
    type := resource.change.after.instance_type
    
    not is_allowed_instance_type(type, env)
    
    msg := sprintf(
        "instance type %v not allowed in %v environment",
        [type, env]
    )
}

# Public S3 buckets
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_s3_bucket"
    
    public_access := resource.change.after.public_access_block
    not public_access.block_public_acls == true
    
    msg := sprintf(
        "S3 bucket %v must block public access",
        [resource.address]
    )
}

# Container security
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_ecs_task_definition"
    
    container := resource.change.after.container_definitions[_]
    not container.user
    
    msg := sprintf(
        "container %v must specify non-root user",
        [container.name]
    )
}

# Container ports
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_ecs_task_definition"
    
    container := resource.change.after.container_definitions[_]
    port := container.portMappings[_].containerPort
    port <= 1024
    
    msg := sprintf(
        "container %v using privileged port %v",
        [container.name, port]
    )
}

# Container insights
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_ecs_cluster"
    
    setting := resource.change.after.setting[_]
    setting.name == "containerInsights"
    not setting.value == "enabled"
    
    msg := sprintf(
        "cluster %v must enable container insights",
        [resource.address]
    )
}

# Volume mounts
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    resource.type == "aws_ecs_task_definition"
    
    container := resource.change.after.container_definitions[_]
    volume := container.mountPoints[_]
    not volume.readOnly
    
    msg := sprintf(
        "volume %v in container %v must be read-only",
        [volume.sourceVolume, container.name]
    )
}

# Encryption
deny[msg] {
    resource := tfplan.resource_changes[_]
    not is_delete(resource)
    
    resource.type == "aws_s3_bucket"
    not resource.change.after.server_side_encryption_configuration
    
    msg := sprintf(
        "bucket %v must enable encryption",
        [resource.address]
    )
}

# Add debug rules
debug_input {
    print("Full tfplan:", tfplan)
}

debug_resources {
    resource := tfplan.resource_changes[_]
    print("Checking resource:", resource)
}