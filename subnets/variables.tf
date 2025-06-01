# terraform/subnets/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC to associate subnets with"
  type        = string
}

variable "internet_gateway_id" {
  description = "The ID of the Internet Gateway for the public route table"
  type        = string
}

variable "public_subnet_cidr_block" {
  description = "The CIDR block for the public subnet"
  type        = string
}

variable "private_subnet_cidr_block" {
  description = "The CIDR block for the private subnet"
  type        = string
}

variable "aws_region_az1" {
  description = "The first availability zone in the chosen AWS region"
  type        = string
}

variable "project_name" {
  description = "A tag to identify resources belonging to this project"
  type        = string
}