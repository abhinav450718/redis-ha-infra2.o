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
  default     = "redis-ha-key"
  description = "SSH key name for EC2 instances"
}

variable "ami_id" {
  type        = string
  default     = "ami-0f5da011d8aca4812"
}
