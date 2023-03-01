#!/bin/bash

# ECS config
echo "ECS_CLUSTER=${ecs_cluster_name}" >>/etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_log_driver}' >>/etc/ecs/ecs.config

start ecs
