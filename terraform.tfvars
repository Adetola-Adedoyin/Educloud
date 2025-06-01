# terraform/terraform.tfvars
aws_region       = "us-east-1"
ami_id           = "ami-084568db4383264d4" # Amazon Linux 2023 AMI
project_name     = "multi-tier-app"
aws_region_az1   = "us-east-1a" # Ensure this AZ exists in your region