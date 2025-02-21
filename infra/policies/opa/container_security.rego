package terraform.container_security

import input as tfplan

# Ensure no privileged containers
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    container := task_def.change.after.container_definitions[_]
    container.privileged == true
    msg := sprintf("Container '%v' must not be privileged", [container.name])
}

# Ensure read-only root filesystem
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    container := task_def.change.after.container_definitions[_]
    not container.readonlyRootFilesystem
    msg := sprintf("Container '%v' must have readonly root filesystem", [container.name])
}

# Ensure no host networking
deny contains msg if {
    task_def := tfplan.resource_changes[_]
    task_def.type == "aws_ecs_task_definition"
    task_def.change.after.network_mode == "host"
    msg := "Task definition must not use host networking"
}