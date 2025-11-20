provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidr   = "10.0.1.0/24"
  private_subnet1_cidr = "10.0.2.0/24"
  private_subnet2_cidr = "10.0.3.0/24"
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
  subnet_id         = module.network.private_subnet1_id
  security_group_id = module.network.db_sg_id
  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

module "redis_replica" {
  source            = "./modules/redis-replica"
  subnet_id         = module.network.private_subnet2_id
  security_group_id = module.network.db_sg_id
  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}
