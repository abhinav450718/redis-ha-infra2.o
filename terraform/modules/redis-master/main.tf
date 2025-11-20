resource "aws_instance" "master" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]

  # IMPORTANT — always use the key created by Terraform
  key_name = var.key_name

  tags = {
    Name    = "redis-master"
    Role    = "master"
    Project = var.project_tag
  }
}
