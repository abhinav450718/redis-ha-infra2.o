#!/bin/bash

KEY=$1
INVENTORY="../ansible/inventory/aws_ec2.yml"

echo "=== Fetching inventory info ==="

MASTER=$(ansible-inventory -i $INVENTORY --host master | jq -r '.ansible_host')
REPLICA=$(ansible-inventory -i $INVENTORY --host replica | jq -r '.ansible_host')

echo "Master: $MASTER"
echo "Replica: $REPLICA"

echo "=== Checking Redis Master Replication Info ==="
ssh -o StrictHostKeyChecking=no -i "$KEY" ec2-user@$MASTER "redis-cli INFO replication | grep role"

echo "=== Checking Redis Replica Replication Info ==="
ssh -o StrictHostKeyChecking=no -i "$KEY" ec2-user@$REPLICA "redis-cli INFO replication | grep -E 'role|master_host|master_link_status'"
