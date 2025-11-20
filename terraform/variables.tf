variable "aws_region" {
  type = string
  default = "sa-east-1"
}

variable "project_tag" {
  type = string
  default = "redis-ha"
}

variable "ami_id" {
  type = string
}

variable "bastion_ssh_cidr" {
  type = string
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type    = string
  default = "10.0.1.0/24"
}

variable "private1_subnet_cidr" {
  type    = string
  default = "10.0.2.0/24"
}

variable "private2_subnet_cidr" {
  type    = string
  default = "10.0.3.0/24"
}
