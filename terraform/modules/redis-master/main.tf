resource "aws_instance" "redis_master" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name    = "redis-master"
    Project = var.project_tag
  }
}
