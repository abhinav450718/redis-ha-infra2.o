variable "aws_region" {
  type    = string
  default = "sa-east-1"
}

variable "project_tag" {
  type    = string
  default = "redis-ha-demo"
}

variable "key_name" {
  type        = string
  default = "redis-ha-key"
}

variable "ami_id" {
  type        = string
  description = "AMI ID for all EC2"
}
