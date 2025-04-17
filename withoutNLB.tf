# ECS Cluster
resource "aws_ecs_cluster" "rabbitmq_cluster" {
  name = "rabbitmq-cluster"
}

# Cloud Map Namespace
resource "aws_service_discovery_private_dns_namespace" "rabbitmq" {
  name        = "rabbitmq.local"
  vpc         = aws_vpc.main.id
  description = "Private DNS namespace for RabbitMQ"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "rabbitmq" {
  family                   = "rabbitmq"
  network_mode             = "awsvpc"
  requires_compatibilities = ["EC2"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  task_role_arn            = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "rabbitmq"
      image     = "rabbitmq:3.8-management"
      essential = true
      portMappings = [
        {
          containerPort = 5672
          hostPort      = 5672
        },
        {
          containerPort = 15672
          hostPort      = 15672
        }
      ]
      mountPoints = [
        {
          sourceVolume  = "rabbitmq_data"
          containerPath = "/var/lib/rabbitmq"
        }
      ]
    }
  ])

  volume {
    name = "rabbitmq_data"
    host_path {
      path = "/ecs/rabbitmq_data"
    }
  }
}

# ECS Service with Cloud Map
resource "aws_ecs_service" "rabbitmq" {
  name            = "rabbitmq"
  cluster         = aws_ecs_cluster.rabbitmq_cluster.id
  task_definition = aws_ecs_task_definition.rabbitmq.arn
  desired_count   = 2
  launch_type     = "EC2"
  network_configuration {
    subnets         = aws_subnet.private.*.id
    security_groups = [aws_security_group.rabbitmq.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.rabbitmq.arn
  }
}

# Cloud Map Service
resource "aws_service_discovery_service" "rabbitmq" {
  name = "rabbitmq"
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.rabbitmq.id
    dns_records {
      type = "A"
      ttl  = 60
    }
    routing_policy = "MULTIVALUE"
  }
  health_check_custom_config {
    failure_threshold = 1
  }
}
