#!/bin/bash

echo "=== Generating dynamic inventory using AWS EC2 plugin ==="
ansible-inventory -i ansible/inventory/aws_ec2.yml --graph
