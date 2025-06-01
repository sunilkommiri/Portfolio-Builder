# terraform/main.tf

data "aws_availability_zones" "available" {} # Get available AZs in the region

# --- VPC ---
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name        = "${var.project_name}-vpc-${var.environment}"
    Environment = var.environment
  }
}

# --- Subnets ---
resource "aws_subnet" "public_az1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az1_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true # Instances in public subnet get public IP
  tags = {
    Name        = "${var.project_name}-public-subnet-az1-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "public_az2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_az2_cidr_block
  availability_zone       = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true
  tags = {
    Name        = "${var.project_name}-public-subnet-az2-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az1_cidr_block
  availability_zone = data.aws_availability_zones.available.names[0]
  tags = {
    Name        = "${var.project_name}-private-subnet-az1-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_subnet" "private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_az2_cidr_block
  availability_zone = data.aws_availability_zones.available.names[1]
  tags = {
    Name        = "${var.project_name}-private-subnet-az2-${var.environment}"
    Environment = var.environment
  }
}

# --- Internet Gateway & NAT Gateway ---
resource "aws_internet_gateway" "main_igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name        = "${var.project_name}-igw-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_eip" "nat_eip" { # Elastic IP for NAT Gateway
  domain = "vpc" # Ensures it's a VPC EIP
  tags = {
    Name        = "${var.project_name}-nat-eip-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_nat_gateway" "main_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_az1.id # NAT Gateway should be in a public subnet
  depends_on    = [aws_internet_gateway.main_igw]
  tags = {
    Name        = "${var.project_name}-nat-gw-${var.environment}"
    Environment = var.environment
  }
}

# --- Route Tables ---
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main_igw.id
  }
  tags = {
    Name        = "${var.project_name}-public-rt-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_route_table_association" "public_az1" {
  subnet_id      = aws_subnet.public_az1.id
  route_table_id = aws_route_table.public.id
}
resource "aws_route_table_association" "public_az2" {
  subnet_id      = aws_subnet.public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main_nat.id
  }
  tags = {
    Name        = "${var.project_name}-private-rt-${var.environment}"
    Environment = var.environment
  }
}
resource "aws_route_table_association" "private_az1" {
  subnet_id      = aws_subnet.private_az1.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_az2" {
  subnet_id      = aws_subnet.private_az2.id
  route_table_id = aws_route_table.private.id
}

# --- Security Groups ---
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg-${var.environment}"
  description = "Security group for Application Load Balancer"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere (if using HTTPS listener)
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg-${var.environment}" }
}

resource "aws_security_group" "ecs_tasks_sg" {
  name        = "${var.project_name}-ecs-tasks-sg-${var.environment}"
  description = "Security group for ECS Fargate tasks"
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow traffic from ALB on container ports
  ingress {
    from_port       = var.frontend_container_port
    to_port         = var.frontend_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only from our ALB
  }
  ingress {
    from_port       = var.backend_container_port
    to_port         = var.backend_container_port
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only from our ALB
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow tasks to pull images from ECR, talk to RDS, etc.
  }
  tags = { Name = "${var.project_name}-ecs-tasks-sg-${var.environment}" }
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.project_name}-rds-sg-${var.environment}"
  description = "Security group for RDS PostgreSQL instance"
  vpc_id      = aws_vpc.main.id

  # Ingress: Allow traffic from ECS tasks (backend) on PostgreSQL port
  ingress {
    from_port       = 5432 # PostgreSQL port
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.ecs_tasks_sg.id] # Only from our ECS tasks
  }
  egress { # Generally not needed for RDS, but good to define if specific outbound is required
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-rds-sg-${var.environment}" }
}

# --- ECR Repositories ---
resource "aws_ecr_repository" "frontend" {
  name                 = "${var.project_name}-frontend"
  image_tag_mutability = "MUTABLE" # Or "IMMUTABLE" for stricter tag management
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "${var.project_name}-frontend-ecr-${var.environment}" }
}

resource "aws_ecr_repository" "backend" {
  name                 = "${var.project_name}-backend"
  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
  tags = { Name = "${var.project_name}-backend-ecr-${var.environment}" }
}

# --- RDS PostgreSQL Instance ---
resource "aws_db_subnet_group" "default" {
  name       = "${var.project_name}-rds-subnet-group-${var.environment}"
  subnet_ids = [aws_subnet.private_az1.id, aws_subnet.private_az2.id] # RDS in private subnets
  tags = {
    Name = "${var.project_name}-rds-subnet-group-${var.environment}"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = 20 # GB (Min for General Purpose SSD)
  engine                 = "postgres"
  engine_version         = "17.14" # Check for latest supported versions
  instance_class         = var.db_instance_class
  db_name                = "${replace(var.project_name, "-", "")}db" # Database name (no hyphens)
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres17"
  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  skip_final_snapshot    = true # For dev/test; set to false for production & configure backups
  multi_az               = false # For dev/test; set to true for production for HA
  publicly_accessible    = false # Keep DB private
  storage_type           = "gp2" # General Purpose SSD

  tags = {
    Name        = "${var.project_name}-rds-postgres-${var.environment}"
    Environment = var.environment
  }
}

# --- ECS (Elastic Container Service) ---
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster-${var.environment}"
  tags = { Name = "${var.project_name}-ecs-cluster-${var.environment}" }
}

# IAM Role for ECS Task Execution (allows ECS tasks to pull images from ECR and send logs)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-ecs-task-execution-role-${var.environment}"
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
  tags = { Name = "${var.project_name}-ecs-task-execution-role-${var.environment}" }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# (Optional) IAM Role for ECS Tasks themselves if they need to interact with other AWS services
# resource "aws_iam_role" "ecs_task_role" { ... }
# resource "aws_iam_role_policy" "ecs_task_role_policy" { ... } # Custom policy for task permissions

# --- CloudWatch Log Group for ECS Tasks ---
resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}-${var.environment}"
  retention_in_days = 7 # Adjust as needed
  tags = { Name = "${var.project_name}-ecs-logs-${var.environment}" }
}

# --- ECS Task Definitions ---
resource "aws_ecs_task_definition" "frontend" {
  family                   = "${var.project_name}-frontend-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 0.5 GB RAM (adjust as needed)
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn         = aws_iam_role.ecs_task_role.arn # If tasks need specific permissions

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-frontend-container"
      image     = var.frontend_ecr_image_uri # This will be updated by Jenkins with specific tags
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.frontend_container_port
          hostPort      = var.frontend_container_port # Not strictly needed for Fargate with awsvpc
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "frontend"
        }
      }
      # environment = [ # Example environment variables for frontend if needed
      #   { name = "REACT_APP_API_URL", value = "http://${aws_lb.main.dns_name}/api" } # Dynamic API URL
      # ]
    }
  ])
  tags = { Name = "${var.project_name}-frontend-task-def-${var.environment}" }
}

resource "aws_ecs_task_definition" "backend" {
  family                   = "${var.project_name}-backend-task-${var.environment}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  # task_role_arn         = aws_iam_role.ecs_task_role.arn # If backend needs specific AWS permissions

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-backend-container"
      image     = var.backend_ecr_image_uri # This will be updated by Jenkins
      cpu       = 256
      memory    = 512
      essential = true
      portMappings = [
        {
          containerPort = var.backend_container_port
          hostPort      = var.backend_container_port
          protocol      = "tcp"
        }
      ]
      environment = [ # Pass database credentials and other configs as environment variables
        { name = "NODE_ENV", value = "production" }, # Or var.environment
        { name = "PORT", value = tostring(var.backend_container_port) },
        { name = "DB_HOST", value = aws_db_instance.default.address },
        { name = "DB_PORT", value = tostring(aws_db_instance.default.port) },
        { name = "DB_USER", value = var.db_username },
        { name = "DB_DATABASE", value = aws_db_instance.default.db_name },
        { name = "CORS_ORIGIN", value = "http://${aws_lb.main.dns_name}" }, # Allow requests from ALB
        # JWT_SECRET and DB_PASSWORD should be passed via AWS Secrets Manager or Parameter Store for production
        # For simplicity in this starter, they are directly referenced here but are sensitive.
        # In a real setup, use secretsmanager_secret_version or ssm_parameter for these.
        { name = "DB_PASSWORD", value = var.db_password }, # This is NOT ideal for production. Use Secrets Manager.
        { name = "JWT_SECRET", value = "YOUR_PRODUCTION_JWT_SECRET_FROM_SECURE_STORE" } # <<< REPLACE or use Secrets Manager
      ]
      secrets = [ # Example using Secrets Manager (preferred for DB_PASSWORD, JWT_SECRET)
        # {
        #   name      = "DB_PASSWORD"
        #   valueFrom = aws_secretsmanager_secret_version.db_password.arn
        # },
        # {
        #   name      = "JWT_SECRET"
        #   valueFrom = aws_secretsmanager_secret_version.jwt_secret.arn
        # }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs_logs.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "backend"
        }
      }
    }
  ])
  tags = { Name = "${var.project_name}-backend-task-def-${var.environment}" }
}

# (Optional) Define aws_secretsmanager_secret and aws_secretsmanager_secret_version resources
# if you want Terraform to manage these secrets. Otherwise, create them manually in AWS Secrets Manager.

# --- Application Load Balancer (ALB) ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb-${var.environment}"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_az1.id, aws_subnet.public_az2.id] # ALB in public subnets
  enable_deletion_protection = false # Set to true for production
  tags = { Name = "${var.project_name}-alb-${var.environment}" }
}

# Target Groups
resource "aws_lb_target_group" "frontend" {
  name        = "${var.project_name}-fe-tg-${var.environment}"
  port        = var.frontend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip" # For Fargate
  health_check {
    enabled             = true
    path                = "/" # Health check path for frontend (e.g., index.html)
    protocol            = "HTTP"
    matcher             = "200-299"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "${var.project_name}-frontend-tg-${var.environment}" }
}

resource "aws_lb_target_group" "backend" {
  name        = "${var.project_name}-be-tg-${var.environment}"
  port        = var.backend_container_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main.id
  target_type = "ip"
  health_check {
    enabled             = true
    path                = "/" # Health check path for backend (e.g., a /health or root route returning 200)
    protocol            = "HTTP"
    matcher             = "200-299" # Check for 200-399 if your root redirects
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
  tags = { Name = "${var.project_name}-backend-tg-${var.environment}" }
}

# ALB Listeners and Rules
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = 80
  protocol          = "HTTP"

  default_action { # Default action is to serve frontend
    type             = "forward"
    target_group_arn = aws_lb_target_group.frontend.arn
  }
  # For HTTPS, you would create another listener on port 443, specify an ACM certificate, etc.
}

resource "aws_lb_listener_rule" "backend_api" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100 # Lower number = higher priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"] # Route traffic starting with /api/ to the backend
    }
  }
}

# --- ECS Services ---
resource "aws_ecs_service" "frontend" {
  name            = "${var.project_name}-frontend-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.frontend.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id] # Run tasks in private subnets
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false # Fargate tasks in private subnets do not need public IP if using NAT for outbound
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.frontend.arn
    container_name   = "${var.project_name}-frontend-container"
    container_port   = var.frontend_container_port
  }

  depends_on = [aws_lb_listener.http] # Ensure listener is created before service tries to register
  deployment_controller {
    type = "ECS" # Rolling updates
  }
  tags = { Name = "${var.project_name}-frontend-service-${var.environment}" }
}

resource "aws_ecs_service" "backend" {
  name            = "${var.project_name}-backend-service-${var.environment}"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.backend.arn
  desired_count   = var.desired_task_count
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.private_az1.id, aws_subnet.private_az2.id]
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.backend.arn
    container_name   = "${var.project_name}-backend-container"
    container_port   = var.backend_container_port
  }

  depends_on = [aws_lb_listener_rule.backend_api]
  deployment_controller {
    type = "ECS"
  }
  tags = { Name = "${var.project_name}-backend-service-${var.environment}" }
}
