output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private1_subnet_id" {
  value = aws_subnet.private1.id
}

output "private2_subnet_id" {
  value = aws_subnet.private2.id
}

output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "redis_db_sg_id" {
  value = aws_security_group.redis_sg.id
}
