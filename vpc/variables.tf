# terraform/vpc/variables.tf
variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "project_name" {
  description = "A tag to identify resources belonging to this project"
  type        = string
}
