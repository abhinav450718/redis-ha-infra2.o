resource "aws_instance" "replica" {
  ami                    = var.ami_id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group_id]
  key_name               = var.key_name

  tags = {
    Name    = "replica-redis"
    Role    = "replica-redis"
    Project = var.project_tag
  }
}
