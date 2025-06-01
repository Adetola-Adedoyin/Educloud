# terraform/variables.tf
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances"
  type        = string
}

variable "project_name" {
  description = "A tag to identify resources belonging to this project"
  type        = string
}

variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block for the private subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "aws_region_az1" {
  description = "The first availability zone in the chosen AWS region (e.g., us-east-1a)"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the EC2 instances"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "The name for your SSH key pair"
  type        = string
  default     = "my-ec2-key"
}