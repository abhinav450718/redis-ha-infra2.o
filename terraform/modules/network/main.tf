terraform {
  required_version = ">= 1.0.0"

  backend "s3" {
    bucket = "redis-ha-terraform-state"
    key    = "state/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source               = "./modules/network"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private1_subnet_cidr = "10.0.2.0/24"
  private2_subnet_cidr = "10.0.3.0/24"

  aws_region        = var.aws_region
  project_tag       = var.project_tag
  bastion_ssh_cidr  = var.bastion_ssh_cidr
}

module "bastion" {
  source            = "./modules/bastion"
  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.bastion_sg_id
  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

module "redis_master" {
  source            = "./modules/redis-master"
  subnet_id         = module.network.private1_subnet_id
  security_group_id = module.network.redis_db_sg_id
  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

module "redis_replica" {
  source            = "./modules/redis-replica"
  subnet_id         = module.network.private2_subnet_id
  security_group_id = module.network.redis_db_sg_id
  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

resource "tls_private_key" "redis_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "redis_keypair" {
  key_name   = "redis-ha-key"
  public_key = tls_private_key.redis_key.public_key_openssh
}

output "private_key_pem" {
  value     = tls_private_key.redis_key.private_key_pem
  sensitive = true
}

output "master_ip" {
  value = module.redis_master.private_ip
}

output "replica_ip" {
  value = module.redis_replica.private_ip
}

output "bastion_ip" {
  value = module.bastion.public_ip
}
