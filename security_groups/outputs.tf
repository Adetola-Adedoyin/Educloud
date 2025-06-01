# terraform/security_groups/outputs.tf
output "alb_sg_id" {
  description = "The ID of the ALB Security Group"
  value       = aws_security_group.alb_sg.id
}

output "frontend_sg_id" {
  description = "The ID of the Frontend Security Group"
  value       = aws_security_group.frontend_sg.id
}

output "backend_sg_id" {
  description = "The ID of the Backend Security Group"
  value       = aws_security_group.backend_sg.id
}

output "database_sg_id" {
  description = "The ID of the Database Security Group"
  value       = aws_security_group.database_sg.id
}