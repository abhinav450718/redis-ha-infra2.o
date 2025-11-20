variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "project_tag" {
  type    = string
  default = "redis-ha"
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

variable "bastion_ssh_cidr" {
  type    = string
  default = "0.0.0.0/0"
}

variable "ami_id" {
  type    = string
  default = "ami-04a81a99f5ec58529"
}
