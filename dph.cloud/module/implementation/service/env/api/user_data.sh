#!/bin/bash

exec > >(tee /var/log/user-data.log | logger -t user-data -s 2>/dev/console) 2>&1

# ECS configuration
echo "Setting up ECS configuration"
echo "ECS_CLUSTER=${ecs_cluster_name}" >>/etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_log_driver}' >>/etc/ecs/ecs.config

echo "Starting ECS agent"
start ecs

echo "Done."
