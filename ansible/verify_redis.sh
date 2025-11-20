#!/bin/bash

KEY=$1
INV="../ansible/inventory/aws_ec2.yml"

echo "=== Fetching inventory info ==="

MASTER=$(ansible-inventory -i $INV --host master | jq -r '.ansible_host')
REPLICA=$(ansible-inventory -i $INV --host replica | jq -r '.ansible_host')

echo "Master: $MASTER"
echo "Replica: $REPLICA"

echo "=== Checking Redis Master ==="
ssh -o StrictHostKeyChecking=no -i "$KEY" ec2-user@$MASTER "redis-cli INFO replication | grep role"

echo "=== Checking Redis Replica ==="
ssh -o StrictHostKeyChecking=no -i "$KEY" ec2-user@$REPLICA "redis-cli INFO replication | grep -E 'role|master_host|master_link_status'"
