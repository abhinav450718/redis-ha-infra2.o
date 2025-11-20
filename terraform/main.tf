terraform {
  required_version = ">= 1.5.0"

  backend "s3" {
    bucket = "redis-ha-terraform-state"
    key    = "state/terraform.tfstate"
    region = "sa-east-1"
  }
}

provider "aws" {
  region = var.aws_region
}

# --------------------------
# NETWORK MODULE
# --------------------------
module "network" {
  source               = "./modules/network"

  aws_region           = var.aws_region
  vpc_cidr             = var.vpc_cidr
  public_subnet_cidr   = var.public_subnet_cidr
  private1_subnet_cidr = var.private1_subnet_cidr
  private2_subnet_cidr = var.private2_subnet_cidr

  project_tag          = var.project_tag
  bastion_ssh_cidr     = var.bastion_ssh_cidr
}

# --------------------------
# BASTION MODULE
# --------------------------
module "bastion" {
  source            = "./modules/bastion"

  subnet_id         = module.network.public_subnet_id
  security_group_id = module.network.bastion_sg_id

  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

# --------------------------
# REDIS MASTER MODULE
# --------------------------
module "redis_master" {
  source            = "./modules/redis-master"

  subnet_id         = module.network.private1_subnet_id
  security_group_id = module.network.redis_db_sg_id

  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

# --------------------------
# REDIS REPLICA MODULE
# --------------------------
module "redis_replica" {
  source            = "./modules/redis-replica"

  subnet_id         = module.network.private2_subnet_id
  security_group_id = module.network.redis_db_sg_id

  key_name          = aws_key_pair.redis_keypair.key_name
  ami_id            = var.ami_id
  project_tag       = var.project_tag
}

# --------------------------
# SSH KEY GENERATION
# --------------------------
resource "tls_private_key" "redis_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "redis_keypair" {
  key_name   = "redis-ha-key"
  public_key = tls_private_key.redis_key.public_key_openssh
}

# --------------------------
# OUTPUTS
# --------------------------
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
