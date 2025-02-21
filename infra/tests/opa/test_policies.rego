package terraform.test

test_deny_root_container {
    deny["Container 'app' must not run as root"] with input as {
        "resource_changes": [{
            "type": "aws_ecs_task_definition",
            "change": {
                "after": {
                    "container_definitions": [{
                        "name": "app",
                        "user": ""
                    }]
                }
            }
        }]
    }
}

test_deny_privileged_port {
    deny["Container 'app' uses privileged port 80. Must be > 1024"] with input as {
        "resource_changes": [{
            "type": "aws_ecs_task_definition",
            "change": {
                "after": {
                    "container_definitions": [{
                        "name": "app",
                        "portMappings": [{
                            "containerPort": 80
                        }]
                    }]
                }
            }
        }]
    }
}