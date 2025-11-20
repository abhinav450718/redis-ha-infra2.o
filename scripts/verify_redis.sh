#!/usr/bin/env bash
set -euo pipefail

KEY_PATH="${1:-/var/lib/jenkins/redis-ha-key.pem}"
INVENTORY="../ansible/inventory/aws_ec2.yml"

echo "=== Fetching inventory info ==="

MASTER_IP=$(ansible-inventory -i "$INVENTORY" --list \
  | python3 -c "import sys, json; inv=json.load(sys.stdin); print(inv['_master']['hosts'][0])")

REPLICA_IP=$(ansible-inventory -i "$INVENTORY" --list \
  | python3 -c "import sys, json; inv=json.load(sys.stdin); print(inv['_replica']['hosts'][0])")

BASTION_IP=$(ansible-inventory -i "$INVENTORY" --list \
  | python3 -c "import sys, json; inv=json.load(sys.stdin); print(inv['_bastion']['hosts'][0])")

echo "Master:  $MASTER_IP"
echo "Replica: $REPLICA_IP"
echo "Bastion: $BASTION_IP"

echo
echo "=== Checking Redis Master Replication Info ==="

ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" \
  "ssh -o StrictHostKeyChecking=no ec2-user@$MASTER_IP \
   'redis-cli INFO replication | egrep \"role|connected_slaves\"'"

echo
echo "=== Checking Redis Replica Replication Info ==="

ssh -i "$KEY_PATH" -o StrictHostKeyChecking=no ec2-user@"$BASTION_IP" \
  "ssh -o StrictHostKeyChecking=no ec2-user@$REPLICA_IP \
   'redis-cli INFO replication | egrep \"role|master_host\"'"
