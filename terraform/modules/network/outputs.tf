###########################
#  OUTPUT – VPC ID
###########################
output "vpc_id" {
  value = aws_vpc.main.id
}

###########################
#  OUTPUT – SUBNET IDS
###########################
output "public_subnet_id" {
  value = aws_subnet.public.id
}

output "private_subnet1_id" {
  value = aws_subnet.private1.id
}

output "private_subnet2_id" {
  value = aws_subnet.private2.id
}

###########################
#  OUTPUT – SECURITY GROUPS
###########################
output "bastion_sg_id" {
  value = aws_security_group.bastion_sg.id
}

output "db_sg_id" {
  value = aws_security_group.db_sg.id
}
