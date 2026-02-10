#!/bin/bash

ACTION=$1

if [ "$ACTION" == "stop" ]; then
    echo "Stopping lab and destroying resources..."
    terraform destroy -auto-approve
elif [ "$ACTION" == "start" ]; then
    echo "Starting lab and provisioning resources..."
    terraform init # Ensures providers are ready
    terraform apply -auto-approve
else
    echo "Usage: ./lab.sh [start|stop]"
fi