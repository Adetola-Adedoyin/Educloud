# terraform/security_groups/variables.tf
variable "vpc_id" {
  description = "The ID of the VPC for security groups"
  type        = string
}

variable "project_name" {
  description = "A tag to identify resources belonging to this project"
  type        = string
}