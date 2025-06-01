# terraform/ec2_instances/variables.tf
variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
}

variable "public_subnet_id" {
  description = "The ID of the public subnet for Frontend EC2"
  type        = string
}

variable "private_subnet_id" {
  description = "The ID of the private subnet for Backend and Database EC2"
  type        = string
}

variable "key_pair_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "frontend_sg_id" {
  description = "The ID of the Frontend Security Group"
  type        = string
}

variable "backend_sg_id" {
  description = "The ID of the Backend Security Group"
  type        = string
}

variable "database_sg_id" {
  description = "The ID of the Database Security Group"
  type        = string
}

variable "project_name" {
  description = "A tag to identify resources belonging to this project"
  type        = string
}