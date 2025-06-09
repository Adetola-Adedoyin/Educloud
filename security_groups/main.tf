# terraform/security_groups/main.tf
resource "aws_security_group" "alb_sg" {
  name        = "${var.project_name}-alb-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all outbound traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-alb-sg"
  }
}

resource "aws_security_group" "frontend_sg" {
  name        = "${var.project_name}-frontend-sg"
  description = "Security group for Frontend EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Allow HTTP from ALB
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere for direct access
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demonstration. Restrict this in production!
  }
  
  # Allow outbound traffic to AWS API endpoints for EC2 instance discovery
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # AWS API endpoints
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-frontend-sg"
  }
}

resource "aws_security_group" "backend_sg" {
  name        = "${var.project_name}-backend-sg"
  description = "Security group for Backend EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 8080 # Backend application port
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id] # Allow traffic from Frontend
  }
  
  ingress {
    from_port       = 80 # Nginx port
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.frontend_sg.id] # Allow traffic from Frontend
  }
  
  ingress {
    from_port   = 3000 # Node.js application port
    to_port     = 3000
    protocol    = "tcp"
    security_groups = [aws_security_group.frontend_sg.id] # Allow traffic from Frontend
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demonstration. Restrict this in production!
  }

  # Allow outbound traffic to AWS API endpoints for EC2 instance discovery
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # AWS API endpoints
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-backend-sg"
  }
}

resource "aws_security_group" "database_sg" {
  name        = "${var.project_name}-database-sg"
  description = "Security group for Database EC2 instances"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306 # Example MySQL port
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.backend_sg.id] # Allow traffic from Backend
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # WARNING: For demonstration. Restrict this in production!
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-database-sg"
  }
}