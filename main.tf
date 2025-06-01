# terraform/main.tf
module "key_pair" {
  source = "./key_pair"
  key_pair_name = var.key_pair_name
}

module "vpc" {
  source = "./vpc"
  project_name = var.project_name
  vpc_cidr_block = var.vpc_cidr_block
}

module "subnets" {
  source = "./subnets"
  vpc_id = module.vpc.vpc_id
  internet_gateway_id = module.vpc.internet_gateway_id
  project_name = var.project_name
  aws_region_az1 = var.aws_region_az1 # Ensure this is passed from root var
  public_subnet_cidr_block = var.public_subnet_cidr_block
  private_subnet_cidr_block = var.private_subnet_cidr_block
}

module "security_groups" {
  source = "./security_groups"
  vpc_id = module.vpc.vpc_id
  project_name = var.project_name
}

module "ec2_instances" {
  source = "./ec2_instances"
  ami_id = var.ami_id # Ensure this is passed from root var
  instance_type = var.instance_type
  key_pair_name = module.key_pair.key_pair_name
  public_subnet_id = module.subnets.public_subnet_id
  private_subnet_id = module.subnets.private_subnet_id
  frontend_sg_id = module.security_groups.frontend_sg_id
  backend_sg_id = module.security_groups.backend_sg_id
  database_sg_id = module.security_groups.database_sg_id
  project_name = var.project_name
}