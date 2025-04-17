# provider "aws" {
#   region = "us-east-1"
# }

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

provider "aws" {
  region = var.region
}


# VPC Configuration
resource "aws_vpc" "common_ai_service_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "MyVPC"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# Public Subnets
resource "aws_subnet" "public_subnet_a" {
  vpc_id                  = aws_vpc.common_ai_service_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
   tags = {
    Name        = "PublicSubnetA"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id                  = aws_vpc.common_ai_service_vpc.id
  cidr_block              = "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name        = "PublicSubnetB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# Private Subnets
resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.common_ai_service_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags = {
    Name        = "PrivateSubnetA"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.common_ai_service_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags = {
    Name        = "PrivateSubnetB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# Internet Gateway and NAT Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.common_ai_service_vpc.id
  tags = {
    Name        = "InternetGateway"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet_a.id
   tags = {
    Name        = "NATGateway"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# Public Route Table
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.common_ai_service_vpc.id
  tags = {
    Name        = "PublicRouteTable"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_route" "public_internet_access" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

# Private Route Table
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.common_ai_service_vpc.id
  tags = {
    Name        = "PrivateRouteTable"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_route" "private_nat_access" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_rt.id
}

# Security Groups
resource "aws_security_group" "private_sg" {
  vpc_id = aws_vpc.common_ai_service_vpc.id
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to your IPs in production
  }
 # Allow inbound HTTP on port 8000 from within the VPC
   ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.common_ai_service_vpc.cidr_block] # Uses VPC's CIDR
  } 
   #Allow inbound HTTP on port 8001 for ingestion service
  ingress {
    from_port   = 8001
    to_port     = 8001
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.common_ai_service_vpc.cidr_block] # Uses VPC's CIDR
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  
  tags = {
    Name        = "PrivateSecurityGroup"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# ECS Configuration
resource "aws_ecs_cluster" "my_cluster" {
  name = "my-cluster"
  tags = {
    Name        = "ECSCluster"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = { Service = "ecs-tasks.amazonaws.com" },
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Name        = "ECSTaskExecutionRole"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_ecs_task_definition" "frontend" {
  family                   = "frontend-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "frontend-container",
      image = "${aws_ecr_repository.frontend_repo.repository_url}:latest",
      portMappings = [
        { containerPort = 3000 }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "chat" {
  family                   = "chat-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "chat-container",
      image = "${aws_ecr_repository.chat_repo.repository_url}:latest",
      portMappings = [
        { containerPort = 8000 }
      ],
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = "/ecs/chat-service"
          "awslogs-region"        = "us-east-1"  #${data.aws_region.current.name}
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

resource "aws_ecs_task_definition" "common_ingestion" {
  family                   = "common-ingestion-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  container_definitions = jsonencode([
    {
      name  = "common-ingestion-container",
      image = "${aws_ecr_repository.ingestion_repo.repository_url}:latest",
      portMappings = [
        { containerPort = 8001 }
      ]
    }
  ])
}

resource "aws_ecs_service" "frontend" {
  name            = "frontend-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.frontend.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }
}

# resource "aws_ecs_service" "chat" {
#   name            = "chat-service"
#   cluster         = aws_ecs_cluster.my_cluster.id
#   task_definition = aws_ecs_task_definition.chat.arn
#   launch_type     = "FARGATE"
#   desired_count   = 1
#   network_configuration {
#     subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
#     security_groups  = [aws_security_group.private_sg.id]
#     assign_public_ip = false
#   }
# }

# Target Group for Chat Service
resource "aws_lb_target_group" "chat_target_group" {
  name        = "chat-target-group"
  port        = 8000
  protocol    = "TCP"
  vpc_id      = aws_vpc.common_ai_service_vpc.id
  target_type = "ip"
}

# Listener for NLB to route traffic to the Chat Service
resource "aws_lb_listener" "chat_listener" {
  load_balancer_arn = aws_lb.ecs_nlb.arn
  port              = 8000
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.chat_target_group.arn
  }
}

resource "aws_ecs_service" "chat" {
  name            = "chat-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.chat.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }
  service_registries {
    registry_arn = aws_service_discovery_service.chat_service.arn
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.chat_target_group.arn
    container_name   = "chat-container"
    container_port   = 8000
  }
}

resource "aws_ecs_service" "common_ingestion" {
  name            = "common-ingestion-service"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.common_ingestion.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }

   load_balancer {
    target_group_arn = aws_lb_target_group.ingestion_target_group.arn
    container_name   = "common-ingestion-container"
    container_port   = 8001
  }
}

# ECR Repositories
resource "aws_ecr_repository" "frontend_repo" {
  name = "frontend-service"
}

resource "aws_ecr_repository" "chat_repo" {
  name = "chat-service"
}

resource "aws_ecr_repository" "ingestion_repo" {
  name = "common-ingestion-service"
}

# AWS CloudMap Setup
resource "aws_service_discovery_private_dns_namespace" "common_ai_service_namespace" {
  name = "common-ai-service-namespace"
  vpc  = aws_vpc.common_ai_service_vpc.id
}

resource "aws_service_discovery_service" "frontend_service" {
  name          = "frontend-service"
  namespace_id  = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
    dns_records {
      ttl = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "chat_service" {
  name          = "chat-service"
  namespace_id  = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
    dns_records {
      ttl = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_service_discovery_service" "ingestion_service" {
  name          = "ingestion-service"
  namespace_id  = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
    dns_records {
      ttl = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# Network Load Balancer (NLB)
resource "aws_lb" "ecs_nlb" {
  name               = "ecs-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  tags = {
    Name        = "ECSNLB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

# VPC Link for API Gateway
resource "aws_api_gateway_vpc_link" "ecs_vpc_link" {
  name        = "ecs-vpc-link"
  target_arns = [aws_lb.ecs_nlb.arn]
}

resource "aws_api_gateway_rest_api" "chat_service_api" {
  name        = "ChatServiceGateway"
  description = "API Gateway for Chat Service"
  tags = {
    Name        = "ChatServiceGateway"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_api_gateway_resource" "api_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_rest_api.chat_service_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "query_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.v1_resource.id
  path_part   = "query"
}

resource "aws_api_gateway_method" "post_method" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  resource_id   = aws_api_gateway_resource.query_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_cloudwatch_log_group" "chat_service_logs" {
  name = "/ecs/chat-service-logs"

  tags = {
    Name        = "ChatServiceLogs"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }

  retention_in_days = 30  #    30 days
}

resource "aws_api_gateway_integration" "post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_api.id
  resource_id             = aws_api_gateway_resource.query_resource.id
  http_method             = aws_api_gateway_method.post_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ecs_nlb.dns_name}:8000/api/v1/query"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  timeout_milliseconds    = 29000
}

 

resource "aws_api_gateway_stage" "chat_service_stage" {
  deployment_id = aws_api_gateway_deployment.chat_service_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  stage_name    = "prod"
}

output "api_gateway_url" {
  value = aws_api_gateway_deployment.chat_service_deployment.invoke_url
}

#################################################################


# Create a new NLB specifically for the Ingestion Service
resource "aws_lb" "ingestion_nlb" {
  name               = "ingestion-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  tags = {
    Name        = "IngestionServiceNLB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}




# Create a new VPC link specifically for the ingestion service
resource "aws_api_gateway_vpc_link" "ingestion_vpc_link" {
  name        = "ingestion-vpc-link"
  target_arns = [aws_lb.ingestion_nlb.arn]
}



# Ingestion Service API Gateway Configuration

resource "aws_api_gateway_rest_api" "ingestion_service_api" {
  name        = "IngestionServiceGateway"
  description = "API Gateway for Ingestion Service"
   tags = {
    Name        = "IngestionServiceNLB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}

resource "aws_api_gateway_resource" "ingestion_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_rest_api.ingestion_service_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "ingestion_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_api_resource.id
  path_part   = "v1"
}

# Create resources for each endpoint
resource "aws_api_gateway_resource" "create_index_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "create_index"
}

resource "aws_api_gateway_resource" "list_indexes_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "list_indexes"
}

resource "aws_api_gateway_resource" "upload_documents_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "upload_documents_with_metadata"
}

resource "aws_api_gateway_resource" "delete_document_by_name_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "delete_document_by_name"
}

resource "aws_api_gateway_resource" "delete_document_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "delete_document"
}

resource "aws_api_gateway_resource" "repopulate_index_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "repopulate_index"
}

# Define HTTP methods for each endpoint
resource "aws_api_gateway_method" "create_index_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.create_index_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "list_indexes_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.list_indexes_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "upload_documents_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.upload_documents_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_document_by_name_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.delete_document_by_name_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "delete_document_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.delete_document_resource.id
  http_method   = "DELETE"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "repopulate_index_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.repopulate_index_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "create_index_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.create_index_resource.id
  http_method             = aws_api_gateway_method.create_index_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/create_index"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}


resource "aws_api_gateway_integration" "list_indexes_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.list_indexes_resource.id
  http_method             = aws_api_gateway_method.list_indexes_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/list_indexes"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "upload_documents_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.upload_documents_resource.id
  http_method             = aws_api_gateway_method.upload_documents_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/upload_documents_with_metadata"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "delete_document_by_name_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.delete_document_by_name_resource.id
  http_method             = aws_api_gateway_method.delete_document_by_name_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "DELETE"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/delete_document_by_name"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "delete_document_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.delete_document_resource.id
  http_method             = aws_api_gateway_method.delete_document_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "DELETE"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/delete_document"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "repopulate_index_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.repopulate_index_resource.id
  http_method             = aws_api_gateway_method.repopulate_index_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/repopulate_index"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

 
output "ingestion_service_api_url" {
  value = aws_api_gateway_deployment.ingestion_service_deployment.invoke_url
}



################
# Health Check Resource
resource "aws_api_gateway_resource" "health_check_resource" {
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
  parent_id   = aws_api_gateway_resource.ingestion_v1_resource.id
  path_part   = "health_check"
}

# Health Check Method
resource "aws_api_gateway_method" "health_check_method" {
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id   = aws_api_gateway_resource.health_check_resource.id
  http_method   = "GET"
  authorization = "NONE"
}

# Health Check Integration
resource "aws_api_gateway_integration" "health_check_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ingestion_service_api.id
  resource_id             = aws_api_gateway_resource.health_check_resource.id
  http_method             = aws_api_gateway_method.health_check_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${aws_lb.ingestion_nlb.dns_name}:8001/api/v1/health_check"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ingestion_vpc_link.id
  timeout_milliseconds    = 29000
}

# Update Deployment to include new integration
resource "aws_api_gateway_deployment" "ingestion_service_deployment" {
  depends_on  = [
    aws_api_gateway_integration.create_index_integration,
    aws_api_gateway_integration.list_indexes_integration,
    aws_api_gateway_integration.upload_documents_integration,
    aws_api_gateway_integration.delete_document_by_name_integration,
    aws_api_gateway_integration.delete_document_integration,
    aws_api_gateway_integration.repopulate_index_integration,
    aws_api_gateway_integration.health_check_integration  
  ]
  rest_api_id = aws_api_gateway_rest_api.ingestion_service_api.id
   
}


resource "aws_api_gateway_stage" "ingestion_service_stage" {
  deployment_id = aws_api_gateway_deployment.ingestion_service_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ingestion_service_api.id
  stage_name    = "prod"
}

 ##################################

 resource "aws_lb_target_group" "ingestion_target_group" {
  name        = "ingestion-target-group"
  port        = 8001
  protocol    = "TCP"
  vpc_id      = aws_vpc.common_ai_service_vpc.id
  target_type = "ip"
}

# Listener for NLB to route traffic to the Ingestion Service
resource "aws_lb_listener" "ingestion_listener" {
  load_balancer_arn = aws_lb.ingestion_nlb.arn
  port              = 8001
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ingestion_target_group.arn
  }
} 




########################

# Health Check Resource
resource "aws_api_gateway_resource" "health_check_resource_chat_service" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.v1_resource.id
  path_part   = "health_check"
}

# Health Check Method
resource "aws_api_gateway_method" "health_check_method_chat_service" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  resource_id   = aws_api_gateway_resource.health_check_resource_chat_service.id
  http_method   = "GET"
  authorization = "NONE"
}

# Health Check Integration
resource "aws_api_gateway_integration" "health_check_integration_chat_service" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_api.id
  resource_id             = aws_api_gateway_resource.health_check_resource_chat_service.id
  http_method             = aws_api_gateway_method.health_check_method_chat_service.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "GET"
  uri                     = "http://${aws_lb.ecs_nlb.dns_name}:8000/api/v1/health_check"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  timeout_milliseconds    = 29000
}


# Method Response for Health Check
resource "aws_api_gateway_method_response" "health_check_200" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  resource_id = aws_api_gateway_resource.health_check_resource_chat_service.id
  http_method = aws_api_gateway_method.health_check_method_chat_service.http_method
  status_code = "200"
}


resource "aws_api_gateway_integration_response" "health_check_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  resource_id = aws_api_gateway_resource.health_check_resource_chat_service.id
  http_method = aws_api_gateway_method.health_check_method_chat_service.http_method
  status_code = "200"
  selection_pattern = ""
}

##########################

# New resources for the chat service API Gateway
resource "aws_api_gateway_resource" "stream_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.v1_resource.id
  path_part   = "stream"
}

resource "aws_api_gateway_resource" "auth_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.v1_resource.id
  path_part   = "auth"
}

resource "aws_api_gateway_resource" "gen_token_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.auth_resource.id
  path_part   = "gen-token"
}

resource "aws_api_gateway_resource" "refresh_token_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
  parent_id   = aws_api_gateway_resource.auth_resource.id
  path_part   = "refresh-token"
}

# Methods for the new endpoints
resource "aws_api_gateway_method" "post_stream_method" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  resource_id   = aws_api_gateway_resource.stream_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_gen_token_method" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  resource_id   = aws_api_gateway_resource.gen_token_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_method" "post_refresh_token_method" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_api.id
  resource_id   = aws_api_gateway_resource.refresh_token_resource.id
  http_method   = "POST"
  authorization = "NONE"
}

# Integrations for the new endpoints
resource "aws_api_gateway_integration" "post_stream_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_api.id
  resource_id             = aws_api_gateway_resource.stream_resource.id
  http_method             = aws_api_gateway_method.post_stream_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ecs_nlb.dns_name}:8000/api/v1/stream"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "post_gen_token_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_api.id
  resource_id             = aws_api_gateway_resource.gen_token_resource.id
  http_method             = aws_api_gateway_method.post_gen_token_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ecs_nlb.dns_name}:8000/api/v1/auth/gen-token"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  timeout_milliseconds    = 29000
}

resource "aws_api_gateway_integration" "post_refresh_token_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_api.id
  resource_id             = aws_api_gateway_resource.refresh_token_resource.id
  http_method             = aws_api_gateway_method.post_refresh_token_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "http://${aws_lb.ecs_nlb.dns_name}:8000/api/v1/auth/refresh-token"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.ecs_vpc_link.id
  timeout_milliseconds    = 29000
}

# Update the deployment to include the new integrations
resource "aws_api_gateway_deployment" "chat_service_deployment" {
  depends_on = [
    aws_api_gateway_integration.post_stream_integration,
    aws_api_gateway_integration.post_gen_token_integration,
    aws_api_gateway_integration.post_refresh_token_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.chat_service_api.id
}


############################
 resource "aws_api_gateway_rest_api" "chat_service_cloudmap_api" {
  name        = "ChatServiceCloudMapGateway"
  description = "API Gateway for Chat Service using Cloud Map"
}

resource "aws_api_gateway_resource" "cloudmap_api_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  parent_id   = aws_api_gateway_rest_api.chat_service_cloudmap_api.root_resource_id
  path_part   = "api"
}

resource "aws_api_gateway_resource" "cloudmap_v1_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  parent_id   = aws_api_gateway_resource.cloudmap_api_resource.id
  path_part   = "v1"
}

resource "aws_api_gateway_resource" "cloudmap_query_resource" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  parent_id   = aws_api_gateway_resource.cloudmap_v1_resource.id
  path_part   = "query"
}

resource "aws_api_gateway_method" "cloudmap_post_method" {
  rest_api_id   = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  resource_id   = aws_api_gateway_resource.cloudmap_query_resource.id
  http_method   = "POST"
  authorization = "NONE"
}


resource "aws_api_gateway_integration" "cloudmap_post_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  resource_id             = aws_api_gateway_resource.cloudmap_query_resource.id
  http_method             = aws_api_gateway_method.cloudmap_post_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:aws:action/InvokeService?ServiceName=chat-service-cloudmap&Namespace=common-ai-service-namespace"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.cloudmap_vpc_link.id
  timeout_milliseconds    = 29000
  request_parameters = {
    "integration.request.path.chat-service" = "method.request.path.chat-service"
  }
}

resource "aws_api_gateway_method_response" "cloudmap_200" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  resource_id = aws_api_gateway_resource.cloudmap_query_resource.id
  http_method = aws_api_gateway_method.cloudmap_post_method.http_method
  status_code = "200"
}

resource "aws_api_gateway_integration_response" "cloudmap_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  resource_id = aws_api_gateway_resource.cloudmap_query_resource.id
  http_method = aws_api_gateway_method.cloudmap_post_method.http_method
  status_code = "200"
  selection_pattern = ""
  depends_on = [aws_api_gateway_integration.cloudmap_post_integration]
}

resource "aws_api_gateway_deployment" "chat_service_cloudmap_deployment" {
  depends_on = [
    aws_api_gateway_integration.cloudmap_post_integration
  ]
  rest_api_id = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
}

resource "aws_api_gateway_stage" "chat_service_cloudmap_stage" {
  deployment_id = aws_api_gateway_deployment.chat_service_cloudmap_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  stage_name    = "prod"
}

output "chat_service_cloudmap_api_url" {
  value = aws_api_gateway_deployment.chat_service_cloudmap_deployment.invoke_url
}

# Connecting API Gateway to Cloud Map
resource "aws_api_gateway_vpc_link" "cloudmap_vpc_link" {
  name        = "cloudmap-vpc-link"
  target_arns = [aws_lb.cloudmap_nlb.arn]
}

resource "aws_api_gateway_integration" "cloudmap_integration" {
  rest_api_id             = aws_api_gateway_rest_api.chat_service_cloudmap_api.id
  resource_id             = aws_api_gateway_resource.cloudmap_query_resource.id
  http_method             = aws_api_gateway_method.cloudmap_post_method.http_method
  type                    = "HTTP_PROXY"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.region}:aws:action/InvokeService?ServiceName=chat-service-cloudmap&Namespace=common-ai-service-namespace"
  connection_type         = "VPC_LINK"
  connection_id           = aws_api_gateway_vpc_link.cloudmap_vpc_link.id
  timeout_milliseconds    = 29000
}

# Configure Cloud Map for Chat Service
resource "aws_service_discovery_service" "chat_service_cloudmap" {
  name          = "chat-service-cloudmap"
  namespace_id  = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.common_ai_service_namespace.id
    dns_records {
      ttl = 300
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

# Updated ECS Service to Register with Cloud Map
resource "aws_ecs_service" "chat_cloudmap" {
  name            = "chat-service-cloudmap"
  cluster         = aws_ecs_cluster.my_cluster.id
  task_definition = aws_ecs_task_definition.chat.arn
  launch_type     = "FARGATE"
  desired_count   = 1
  network_configuration {
    subnets          = [aws_subnet.private_subnet_a.id, aws_subnet.private_subnet_b.id]
    security_groups  = [aws_security_group.private_sg.id]
    assign_public_ip = false
  }

  # This block registers the service with Cloud Map
  service_registries {
    registry_arn = aws_service_discovery_service.chat_service_cloudmap.arn
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.chat_target_group.arn
    container_name   = "chat-container"
    container_port   = 8000
  }
}


# Create a new NLB specifically for Cloud Map integration
resource "aws_lb" "cloudmap_nlb" {
  name               = "cloudmap-nlb"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.public_subnet_a.id, aws_subnet.public_subnet_b.id]
  tags = {
    Name        = "CloudMapNLB"
    Project     = "common_ai_service"
    Environment = "Dev"
    Owner       = "company-AI"
    s_expdate   = "2030-12-31"
    s_owner     = "company-AI"
    s_project   = "common_ai_service"
  }
}
