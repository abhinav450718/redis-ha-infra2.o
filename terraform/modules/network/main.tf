##############
#   VPC
##############
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name    = "redis-ha-vpc"
    Project = "redis-ha-demo"
  }
}

##############
#   INTERNET GATEWAY
##############
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "redis-ha-igw"
  }
}

##############
#   PUBLIC SUBNET
##############
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "sa-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

##############
#   PRIVATE SUBNET 1 (MASTER)
##############
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet1_cidr
  availability_zone = "sa-east-1a"

  tags = {
    Name = "private-subnet-1"
  }
}

##############
#   PRIVATE SUBNET 2 (REPLICA)
##############
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet2_cidr
  availability_zone = "sa-east-1a"

  tags = {
    Name = "private-subnet-2"
  }
}

##############
#   SECURITY GROUP – BASTION
##############
resource "aws_security_group" "bastion_sg" {
  name   = "bastion-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "SSH from internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

##############
#   SECURITY GROUP – REDIS
##############
resource "aws_security_group" "db_sg" {
  name   = "redis-db-sg"
  vpc_id = aws_vpc.main.id

  ingress {
    description = "Redis port"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  ingress {
    description     = "SSH from Bastion"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
