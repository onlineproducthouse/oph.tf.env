# OPH Environment Terraform Modules - Application Platform

![diagram](../../assets/oph.tf.env.platform.png)

## Dependencies

This module assumes the [network](../network/README.md) module is provisioned.

## Resources provisioned

The resources provisioned by this module are as follows:
- AWS CloudWatch Log Group
- AWS IAM Policy for AWS EC2 Launch Template
- AWS IAM Role for ECS
- AWS IAM Instance Profile for EC2 instance
- AWS S3 bucket for application storage needs
- AWS ECS Cluster
- AWS Security Group
- AWS EC2 Launch Template
- AWS Auto Scaling Group for AWS ECS Cluster

## Switchboard

Switchboard variables for the platform module are as follows:

- sb_compute - Type: `bool`
  Provisions compute resources for use in ECS.

- sb_storage - Type: `bool`
  Provisions an AWS S3 bucket for use by container applications.