terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

# Network
resource "aws_vpc" "vpc" {
  cidr_block = "10.1.0.0/16"
  tags = var.resource_tags
}

resource "aws_subnet" "internet_sn" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.1.0.0/17"
  map_public_ip_on_launch = "true"
  tags = var.resource_tags
}

resource "aws_internet_gateway" "internet_gw" {
  vpc_id = aws_vpc.vpc.id
  tags = var.resource_tags
}

resource "aws_route_table" "internet_route_table" {
  vpc_id = aws_vpc.vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gw.id
  }
  tags = var.resource_tags
}

resource "aws_route_table_association" "internet_route_table_association" {
  subnet_id      = aws_subnet.internet_sn.id
  route_table_id = aws_route_table.internet_route_table.id
}

resource "aws_security_group" "allow_http_https" {
  name        = "allow_http"
  description = "Allow HTTP and HTTPS traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "HTTP from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  
  ingress {
    description      = "HTTPS from VPC"
    from_port        = 443
    to_port          = 443
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = var.resource_tags
}

# Network LoadBalancer
resource "aws_lb" "ecs" {
  name               = "ecs-webserver"
  internal           = false
  load_balancer_type = "network"
  subnets            = [aws_subnet.internet_sn.id]
  tags = var.resource_tags
}

resource "aws_lb_target_group" "ecs" {
  name        = "ecs-target"
  target_type = "ip"
  port        = 80
  protocol    = "TCP"
  vpc_id      = aws_vpc.vpc.id
}

resource "aws_lb_listener" "ecs" {
  load_balancer_arn = aws_lb.ecs.arn
  port              = "80"
  protocol          = "TCP" 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs.arn
  }
}

# ECS
resource "aws_ecs_cluster" "cluster" {
  name = "terraform-cluster"
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
  tags = var.resource_tags
}

resource "aws_ecs_task_definition" "webserver" {
  family                   = "webserver"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 1024
  memory                   = 2048
  container_definitions    = <<TASK_DEFINITION
[
  {
    "name": "${var.service_name}",
    "image": "${var.image}",
    "containerPort": 80,
    "cpu": 1024,
    "memory": 2048,
    "essential": true,
    "portMappings":
      [
        {
          "containerPort": 80,
          "hostPort": 80,
          "protocol": "tcp"
        }
      ]
  }
]
TASK_DEFINITION

  runtime_platform {
    operating_system_family = "LINUX"
  }
  tags = var.resource_tags
}

resource "aws_ecs_service" "nginx" {
  name            = var.service_name
  cluster         = aws_ecs_cluster.cluster.id
  task_definition = aws_ecs_task_definition.webserver.arn
  desired_count   = var.replicas
  launch_type     = "FARGATE"
  network_configuration {
    subnets = [aws_subnet.internet_sn.id]
    assign_public_ip = true
    security_groups  = [aws_security_group.allow_http_https.id]
  }
  enable_ecs_managed_tags = true
  load_balancer {
    target_group_arn = aws_lb_target_group.ecs.arn
    container_name   = var.service_name
    container_port   = 80
  }
  tags           = var.resource_tags
}