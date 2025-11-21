variable "subnet_id" {}
variable "security_group_id" {}
variable "key_name" {}
variable "ami_id" {}
variable "project_tag" {}

resource "aws_instance" "replica" {
  ami           = var.ami_id
  instance_type = "t2.micro"
  subnet_id     = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name      = var.key_name

  tags = {
    Name = "${var.project_tag}-redis-replica"
  }
}

output "private_ip" {
  value = aws_instance.replica.private_ip
}
