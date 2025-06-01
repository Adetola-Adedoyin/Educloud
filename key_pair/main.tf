# terraform/key_pair/main.tf
resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_pair_name
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "local_file" "private_key" {
  content  = tls_private_key.rsa.private_key_pem
  filename = "${path.module}/${var.key_pair_name}.pem"
  file_permission = "0400" # Important: Set permissions to 400 for SSH
}