# ECS Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = local.ecs_cluster_name

  #Enable container insights
  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name        = local.ecs_cluster_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# ECS Task Definition
resource "aws_ecs_task_definition" "task" {
  family                   = local.task_family_name
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.workspace_config.task_cpu
  memory                   = var.workspace_config.task_memory
  task_role_arn      = aws_iam_role.ecs_task_role.arn
  execution_role_arn = aws_iam_role.ecs_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = local.container_name
      image     = "${aws_ecr_repository.ecr_repo.repository_url}:latest"
      cpu       = var.workspace_config.task_cpu
      memory    = var.workspace_config.task_memory
      user      = var.workspace_config.container_user
      essential = true
      
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/${local.name_prefix}"
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
          "awslogs-multiline-pattern" = "^\\[\\d{4}-\\d{2}-\\d{2}"  # For better log parsing
        }
      }

      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command     = [
          "CMD-SHELL",
          "curl -f http://localhost:${var.container_port}/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 60
      }

      # Enhanced container security settings
      readonlyRootFilesystem = true
      privileged             = false
      
      linuxParameters = {
        initProcessEnabled = true
        capabilities = {
          drop = ["ALL"]
        }
      }
      
      environment = [
        {
          name  = "NODE_ENV"
          value = terraform.workspace
        },
        {
          name  = "APP_VERSION"
          value = var.app_version
        }
      ]

      mountPoints = []
      volumesFrom = []
    }
  ])

  lifecycle {
    ignore_changes = [
      container_definitions,
      task_role_arn,
      execution_role_arn,
    ]
  }

  tags = merge(local.common_tags, {
    Name = local.task_family_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# ECS Service with Auto Scaling
resource "aws_ecs_service" "ecs_service" {
  name            = local.ecs_service_name
  cluster         = aws_ssm_parameter.ecs_cluster_arn.value
  task_definition = aws_ssm_parameter.ecs_task_definition_arn.value
  launch_type     = "FARGATE"
  deployment_maximum_percent = 200
  deployment_minimum_healthy_percent = 100
  force_new_deployment = true

  network_configuration {
    subnets         = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    security_groups = [data.aws_ssm_parameter.ecs_sg_id.value]
    assign_public_ip = false
    
    #checkov:skip=CKV_AWS_333: "Ensure ECS services do not have public IP addresses assigned to them automatically"
  }

  load_balancer {
    target_group_arn = data.aws_ssm_parameter.alb_target_group_arn.value
    container_name   = local.container_name
    container_port   = var.container_port
  }

  deployment_controller {
    type = "ECS"
  }
  desired_count = var.workspace_config.ecs_min_capacity

  lifecycle {
    ignore_changes = [task_definition, desired_count]
  }

  enable_execute_command = false

  service_registries {
    registry_arn = aws_service_discovery_service.ecs.arn
  }

  tags = merge(local.common_tags, {
    Name        = local.ecs_service_name,
    Environment = var.environment,
    Project     = var.project_name,
    Owner       = var.owner
  })
}

# Auto Scaling Configuration
resource "aws_appautoscaling_target" "ecs_scaling_target" {
  max_capacity       = var.workspace_config.ecs_max_capacity
  min_capacity       = var.workspace_config.ecs_min_capacity
  resource_id        = "service/${aws_ecs_cluster.ecs_cluster.name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

# CPU-based Auto Scaling
resource "aws_appautoscaling_policy" "cpu_scaling" {
  name               = "${local.name_prefix}-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.workspace_config.cpu_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300

    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
  }
}

# Memory-based Auto Scaling
resource "aws_appautoscaling_policy" "memory_scaling" {
  name               = "${local.name_prefix}-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace

  target_tracking_scaling_policy_configuration {
    target_value = var.workspace_config.memory_target_value
    scale_in_cooldown  = 300
    scale_out_cooldown = 300
    
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
  }
}

# Schedule-based scaling for off-hours
resource "aws_appautoscaling_scheduled_action" "scale_down_night" {
  name               = "scale-down-night"
  service_namespace  = aws_appautoscaling_target.ecs_scaling_target.service_namespace
  resource_id        = aws_appautoscaling_target.ecs_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_scaling_target.scalable_dimension
  schedule           = "cron(0 0 * * ? *)"  # 12 AM UTC

  scalable_target_action {
    min_capacity = var.workspace_config.night_min_capacity
    max_capacity = var.workspace_config.night_max_capacity
  }
}

# Add service discovery
resource "aws_service_discovery_private_dns_namespace" "ecs" {
  name        = "${local.name_prefix}.local"
  description = "Service Discovery Namespace for ECS"
  vpc         = data.aws_ssm_parameter.vpc_id.value

  tags = merge(local.common_tags, {
    Name        = "${local.name_prefix}.local"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      description,
      vpc
    ]
  }
}

resource "aws_service_discovery_service" "ecs" {
  name = local.ecs_service_name

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.ecs.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }

  tags = merge(local.common_tags, {
    Name        = local.ecs_service_name
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      name,
      description
    ]
  }
}