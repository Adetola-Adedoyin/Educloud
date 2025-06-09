# terraform/ec2_instances/main.tf

# Create IAM role for EC2 instances to allow them to discover other instances
resource "aws_iam_role" "ec2_instance_role" {
  name = "${var.project_name}-ec2-instance-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Create IAM policy for EC2 instance discovery
resource "aws_iam_policy" "ec2_instance_discovery" {
  name        = "${var.project_name}-ec2-instance-discovery"
  description = "Policy to allow EC2 instances to discover other instances"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags"
        ]
        Effect   = "Allow"
        Resource = "*"
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "ec2_instance_discovery_attachment" {
  role       = aws_iam_role.ec2_instance_role.name
  policy_arn = aws_iam_policy.ec2_instance_discovery.arn
}

# Create instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "${var.project_name}-ec2-instance-profile"
  role = aws_iam_role.ec2_instance_role.name
}

resource "aws_instance" "database" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.private_subnet_id
  vpc_security_group_ids = [var.database_sg_id]
  key_name             = var.key_pair_name
  user_data            = file("${path.module}/../user_data/database_user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name

  tags = {
    Name = "${var.project_name}-Database-EC2"
  }
}

resource "aws_instance" "backend" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.private_subnet_id
  vpc_security_group_ids = [var.backend_sg_id]
  key_name             = var.key_pair_name
  user_data            = file("${path.module}/../user_data/backend_user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  depends_on           = [aws_instance.database]

  tags = {
    Name = "${var.project_name}-Backend-EC2"
  }
}

resource "aws_instance" "frontend" {
  ami                  = var.ami_id
  instance_type        = var.instance_type
  subnet_id            = var.public_subnet_id
  vpc_security_group_ids = [var.frontend_sg_id]
  key_name             = var.key_pair_name
  user_data            = file("${path.module}/../user_data/frontend_user_data.sh")
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  depends_on           = [aws_instance.backend]

  tags = {
    Name = "${var.project_name}-Frontend-EC2"
  }
}