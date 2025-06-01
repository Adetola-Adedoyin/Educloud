# terraform/ec2_instances/main.tf
resource "aws_instance" "frontend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_id
  vpc_security_group_ids = [var.frontend_sg_id]
  key_name      = var.key_pair_name
  user_data     = file("${path.module}/../user_data/frontend_user_data.sh")

  tags = {
    Name = "${var.project_name}-Frontend-EC2"
  }
}

resource "aws_instance" "backend" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids = [var.backend_sg_id]
  key_name      = var.key_pair_name
  user_data     = file("${path.module}/../user_data/backend_user_data.sh")

  tags = {
    Name = "${var.project_name}-Backend-EC2"
  }
}

resource "aws_instance" "database" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = var.private_subnet_id
  vpc_security_group_ids = [var.database_sg_id]
  key_name      = var.key_pair_name
  user_data     = file("${path.module}/../user_data/database_user_data.sh")

  tags = {
    Name = "${var.project_name}-Database-EC2"
  }
}