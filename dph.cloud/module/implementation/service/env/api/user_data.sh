#!/bin/bash

# Download amazon-cloudwatch-agent
yum install -y amazon-cloudwatch-agent
wget https://s3.eu-west-1.amazonaws.com/amazoncloudwatch-agent-eu-west-1/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm
rpm -U ./amazon-cloudwatch-agent.rpm

# Configure amazon-cloudwatch-agent
echo "{
  "agent": {
    "region": "eu-west-1",
    "metrics_collection_interval": 10,
    "logfile": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
    "run_as_user": "cwagent"
  },
  "metrics": {
    "namespace": "${ecs_cluster_name}-metrics",
    "aggregation_dimensions" : [["ImageId"], ["InstanceId", "InstanceType"], ["d1"],[]],
    "force_flush_interval" : 30,
    "append_dimensions": {
      "ImageId": "${aws:ImageId}",
      "InstanceId": "${aws:InstanceId}",
      "InstanceType": "${aws:InstanceType}",
      "AutoScalingGroupName": "${aws:AutoScalingGroupName}"
    }
    "metrics_collected": {
      "cpu": {
        "resources": [
          "*"
        ],
        "measurement": [
          {"name": "cpu_usage_idle", "rename": "CPU_USAGE_IDLE", "unit": "Percent"},
          {"name": "cpu_usage_nice", "unit": "Percent"},
          "cpu_usage_guest"
        ],
        "totalcpu": false,
        "metrics_collection_interval": 10
      },
      "disk": {
        "resources": [
          "/",
          "/tmp"
        ],
        "measurement": [
          {"name": "free", "rename": "DISK_FREE", "unit": "Gigabytes"},
          "total",
          "used"
        ],
          "ignore_file_system_types": [
          "sysfs", "devtmpfs"
        ],
        "metrics_collection_interval": 60
      },
      "diskio": {
        "resources": [
          "*"
        ],
        "measurement": [
          "reads",
          "writes",
          "read_time",
          "write_time",
          "io_time"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used",
          "swap_free",
          "swap_used_percent"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used",
          "mem_cached",
          "mem_total"
        ],
        "metrics_collection_interval": 1
      },
      "net": {
        "resources": [
          "eth0"
        ],
        "measurement": [
          "bytes_sent",
          "bytes_recv",
          "drop_in",
          "drop_out"
        ]
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_syn_sent",
          "tcp_close"
        ],
        "metrics_collection_interval": 60
      },
      "processes": {
        "measurement": [
          "running",
          "sleeping",
          "dead"
        ]
      }
    }
  },
  "logs": {
    "log_stream_name": "${ecs_cluster_name}/{instance_id}",
    "force_flush_interval" : 15,
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/amazon-cloudwatch-agent.log",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/dmesg",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/dmesg",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/messages",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/messages",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/docker",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/docker",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/ecs/ecs-init.log.*",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/ecs/ecs-init.log",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/ecs/ecs-agent.log.*",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/ecs/ecs-agent.log",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/ecs/audit.log.*",
            "log_group_name": "${logs_group}/${logs_stream_prefix}/var/log/ecs/audit.log",
            "log_stream_name": "${ecs_cluster_name}/{instance_id}",
            "timezone": "UTC"
          },
        ]
      }
    }
  }
}" >>"/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

# Start amazon-cloudwatch-agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:"/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json"

# ECS configuration
echo "ECS_CLUSTER=${ecs_cluster_name}" >>/etc/ecs/ecs.config
echo 'ECS_AVAILABLE_LOGGING_DRIVERS=${ecs_log_driver}' >>/etc/ecs/ecs.config

start ecs

echo "Done"
