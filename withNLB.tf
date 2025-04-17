# NLB
resource "aws_lb" "rabbitmq" {
  name               = "rabbitmq-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = aws_subnet.public.*.id
}

# Target Group for AMQP
resource "aws_lb_target_group" "amqp" {
  name     = "amqp"
  port     = 5672
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

# Target Group for Management
resource "aws_lb_target_group" "management" {
  name     = "management"
  port     = 15672
  protocol = "TCP"
  vpc_id   = aws_vpc.main.id
  target_type = "ip"
}

# Listener for AMQP
resource "aws_lb_listener" "amqp" {
  load_balancer_arn = aws_lb.rabbitmq.arn
  port              = 5672
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.amqp.arn
  }
}

# Listener for Management
resource "aws_lb_listener" "management" {
  load_balancer_arn = aws_lb.rabbitmq.arn
  port              = 15672
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.management.arn
  }
}

# ECS Service with NLB
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
  load_balancer {
    target_group_arn = aws_lb_target_group.amqp.arn
    container_name   = "rabbitmq"
    container_port   = 5672
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.management.arn
    container_name   = "rabbitmq"
    container_port   = 15672
  }
}
