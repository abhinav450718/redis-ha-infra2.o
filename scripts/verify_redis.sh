#!/bin/bash

SSH_KEY="$1"

if [ -z "$SSH_KEY" ]; then
  echo "Usage: verify_redis.sh <private_key>"
  exit 1
fi

echo "=== Fetching inventory info ==="
MASTER=$(ansible-inventory -i ansible/inventory/aws_ec2.yml --host master-redis | grep ansible_host | awk '{print $2}')
REPLICA=$(ansible-inventory -i ansible/inventory/aws_ec2.yml --host replica-redis | grep ansible_host | awk '{print $2}')
BASTION=$(ansible-inventory -i ansible/inventory/aws_ec2.yml --host bastion | grep ansible_host | awk '{print $2}')

echo "Master:  $MASTER"
echo "Replica: $REPLICA"
echo "Bastion: $BASTION"
echo ""

echo "=== Checking Redis Master Replication Info ==="
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@$BASTION \
  "ssh -i /home/ubuntu/id_rsa ubuntu@$MASTER 'redis-cli INFO replication'"

echo "=== Checking Redis Replica Replication Info ==="
ssh -i "$SSH_KEY" -o StrictHostKeyChecking=no ubuntu@$BASTION \
  "ssh -i /home/ubuntu/id_rsa ubuntu@$REPLICA 'redis-cli INFO replication'"
