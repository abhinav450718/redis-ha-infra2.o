########################
# VPC
########################

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "redis-ha-vpc"
    Project = var.project_tag
  }
}

########################
# Internet Gateway
########################

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name    = "redis-ha-igw"
    Project = var.project_tag
  }
}

########################
# Subnets
########################

# Public subnet (bastion)
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  availability_zone       = "${var.aws_region}a"
  map_public_ip_on_launch = true

  tags = {
    Name    = "redis-ha-public"
    Project = var.project_tag
  }
}

# Private subnet 1 (redis master)
resource "aws_subnet" "private1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private1_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "redis-ha-private1"
    Project = var.project_tag
  }
}

# Private subnet 2 (redis replica)
resource "aws_subnet" "private2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private2_subnet_cidr
  availability_zone = "${var.aws_region}a"

  tags = {
    Name    = "redis-ha-private2"
    Project = var.project_tag
  }
}

########################
# Route tables
########################

# Public route table (to Internet)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name    = "redis-ha-public-rt"
    Project = var.project_tag
  }
}

# Associate public subnet with public route table
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

# NOTE:
# We leave private1/private2 on the main route table (local only).
# That’s enough for bastion → private instances SSH via VPC.

########################
# Security Groups
########################

# Bastion SG – SSH from your IP + allow egress anywhere
resource "aws_security_group" "bastion_sg" {
  name        = "bastion-sg"
  description = "Allow SSH from admin, egress to anywhere"
  vpc_id      = aws_vpc.main.id

  # SSH from your public IP or office IP
  ingress {
    description = "SSH from admin"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    description = "allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "bastion-sg"
    Project = var.project_tag
  }
}

# Redis DB SG – SSH from bastion + Redis from inside VPC
resource "aws_security_group" "db_sg" {
  name        = "redis-db-sg"
  description = "Redis DB SG – SSH from bastion and Redis port inside VPC"
  vpc_id      = aws_vpc.main.id

  # SSH only from bastion SG
  ingress {
    description      = "SSH from bastion"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    security_groups  = [aws_security_group.bastion_sg.id]
    cidr_blocks      = []
    ipv6_cidr_blocks = []
  }

  # Redis port 6379 from inside VPC (master <-> replica, bastion tests, etc.)
  ingress {
    description = "Redis 6379 inside VPC"
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  egress {
    description = "allow all egress"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name    = "redis-db-sg"
    Project = var.project_tag
  }
}
