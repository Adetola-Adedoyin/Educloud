# terraform/ec2_instances/outputs.tf
output "frontend_public_ip" {
  description = "The public IP address of the Frontend EC2 instance"
  value       = aws_instance.frontend.public_ip
}

output "backend_private_ip" {
  description = "The private IP address of the Backend EC2 instance"
  value       = aws_instance.backend.private_ip
}

output "database_private_ip" {
  description = "The private IP address of the Database EC2 instance"
  value       = aws_instance.database.private_ip
}
output "backend_public_ip" {
  description = "Public IP address of the backend server"
  value       = aws_instance.backend.public_ip
}