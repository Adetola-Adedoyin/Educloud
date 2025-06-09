# terraform/outputs.tf
output "frontend_public_ip" {
  description = "The public IP address of the Frontend EC2 instance"
  value       = module.ec2_instances.frontend_public_ip
}

output "frontend_website_url" {
  description = "URL to access the frontend website"
  value       = "http://${module.ec2_instances.frontend_public_ip}"
}

output "backend_private_ip" {
  description = "The private IP address of the Backend EC2 instance"
  value       = module.ec2_instances.backend_private_ip
}

output "database_private_ip" {
  description = "The private IP address of the Database EC2 instance"
  value       = module.ec2_instances.database_private_ip
}

output "ssh_private_key_path" {
  description = "Path to the generated SSH private key"
  value       = module.key_pair.private_key_path
}