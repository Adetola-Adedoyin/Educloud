# terraform/key_pair/outputs.tf
output "key_pair_name" {
  description = "The name of the generated key pair"
  value       = aws_key_pair.generated_key.key_name
}

output "private_key_path" {
  description = "The path to the generated private key file"
  value       = local_file.private_key.filename
}