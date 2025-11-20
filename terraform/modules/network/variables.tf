variable "vpc_cidr" {
  type        = string
  description = "CIDR for the VPC"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for public subnet"
}

variable "private1_subnet_cidr" {
  type        = string
  description = "CIDR for private subnet 1 (master)"
}

variable "private2_subnet_cidr" {
  type        = string
  description = "CIDR for private subnet 2 (replica)"
}

variable "aws_region" {
  type        = string
  description = "AWS region, e.g., sa-east-1"
}

variable "project_tag" {
  type        = string
  description = "Tag for project name"
}

variable "bastion_ssh_cidr" {
  type        = string
  description = "Your public IP/CIDR allowed to SSH into bastion"
}
