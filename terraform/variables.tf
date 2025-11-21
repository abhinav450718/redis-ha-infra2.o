variable "aws_region" { type = string }

variable "vpc_cidr" { type = string }
variable "public_subnet_cidr" { type = string }
variable "private1_subnet_cidr" { type = string }
variable "private2_subnet_cidr" { type = string }

variable "project_tag" { type = string }
variable "bastion_ssh_cidr" { type = string }
variable "ami_id" { type = string }
