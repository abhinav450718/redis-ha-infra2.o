output "private_ip" {
  value = aws_instance.redis_replica.private_ip
}

output "instance_id" {
  value = aws_instance.redis_replica.id
}
