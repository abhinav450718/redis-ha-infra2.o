output "bastion_ip" {
  value = module.bastion.public_ip
}

output "master_ip" {
  value = module.redis_master.private_ip
}

output "replica_ip" {
  value = module.redis_replica.private_ip
}

output "all_hosts" {
  value = jsonencode({
    bastion = module.bastion.public_ip
    master  = module.redis_master.private_ip
    replica = module.redis_replica.private_ip
  })
}
