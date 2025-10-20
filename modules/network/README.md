# OPH Environment Terraform Modules - Network

This module is for provisioning network infrastructure required for running docker containers in AWS ECS EC2 instances.

This module *does not* deal with docker or container specific networking, rather networking on AWS infrastructure to support container applications.

## Resources provisioned

The resources provisioned by this module are as follows:
- AWS VPC
- AWS Internet Gateway
- AWS Subnets (public and private)
- AWS Elastic IP
- AWS NAT Gateway (for each subnet)
- AWS Route Tables (for each subnet)
- AWS Routes (for each route table)
- AWS Security Group
- AWS Application Load Balancer

## Switchboard

Switchboard variables for the network module are as follows:

- sb_eip - Type: `bool`  
  Creates an Elastic IP for each public subnet. Elastic IPs are required for creating a NAT Gateway. If the NAT Gateway value `sb_nat_gateway` is set to `true`, this will be true as well.

- sb_nat_gateway - Type: `bool`  
  Creates a NAT Gateway in each public subnet. Requires an Elastic IP is provisioned for each public subnet. Setting this value to `true` automatically provisions Elastic IPs in the network created

- sb_alb - Type: `bool`  
  Creates an Application Load Balancer in the network created.