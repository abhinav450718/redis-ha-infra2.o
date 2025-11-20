resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "${var.project_tag}-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_tag}-public-subnet"
  }
}

resource "aws_subnet" "private1_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private1_subnet_cidr

  tags = {
    Name = "${var.project_tag}-private1-subnet"
  }
}

resource "aws_subnet" "private2_subnet" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private2_subnet_cidr

  tags = {
    Name = "${var.project_tag}-private2-subnet"
  }
}

resource "aws_security_group" "bastion_sg" {
  name        = "${var.project_tag}-bastion-sg"
  description = "Allow SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.bastion_ssh_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "redis_db_sg" {
  name        = "${var.project_tag}-redis-db-sg"
  description = "Allow Redis ports between master and replica"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 6379
    to_port     = 6379
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.private1_subnet.cidr_block, aws_subnet.private2_subnet.cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_subnet_id" {
  value = aws_subnet.public_subnet.id
}

output "private1_subnet_id" {
  value = aws_subnet.private1_subnet.id
}

output "private2_subnet_id" {
  value = aws_subnet.private2_subnet.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "redis_db_sg_id" {
  value = aws_security_group.redis_db_sg.id
}
