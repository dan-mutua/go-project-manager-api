provider "aws" {
  region  = "us-west-1" 
  profile = "alfa" 
}

# VPC
resource "aws_vpc" "go_vpc" {
  cidr_block = "10.0.0.0/16"
}

# Subnet
resource "aws_subnet" "go_subnet" {
  vpc_id            = aws_vpc.go_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-1a"
}

# Security Group
resource "aws_security_group" "go_service_sg" {
  name        = "go_service_sg"
  description = "Allow traffic to ECS service"
  vpc_id      = aws_vpc.go_vpc.id

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"  # Allows all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "go_cluster" {
  name = "go_cluster"
}

# ECR Repository
resource "aws_ecr_repository" "go_repository" {
  name = "go_repository"
}

# IAM Role for ECS Task
resource "aws_iam_role" "ecs_task_execution" {
  name = "ecsTaskExecutionRole2"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

# IAM Policy Attachment for ECS Task Role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ECS Task Definition
resource "aws_ecs_task_definition" "example" {
  family                   = "go_task_definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution.arn
  memory                   = "512"
  cpu                      = "256"

  container_definitions = jsonencode([{
    name      = "example"
    image     = "${aws_ecr_repository.go_repository.repository_url}:latest"
    essential = true

    portMappings = [{
      containerPort = 8080
      hostPort      = 8080
    }]
  }])
}

# ECS Service
resource "aws_ecs_service" "go_service" {
  name            = "go_service"
  cluster         = aws_ecs_cluster.go_cluster.id
  task_definition = aws_ecs_task_definition.example.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.go_subnet.id]  
    security_groups  = [aws_security_group.go_service_sg.id]      
    assign_public_ip = true
  }
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.go_repository.repository_url
}
