# OPH Environment Terraform Modules - Project - API

This module provisions infrastructure required for hosting an API

## Dependencies

This module assumes the native network and platform modules, or something similar, is provisioned.

From the network module, this module requires:
- VPC ID
- ALB ARN
- ALB Hosted Zone ID
- ALB DNS Name

From the platform module, this module requires:
- ASG Name
- Cluster ID
- Cluster Role ARN
- CloudWatch Log Group

## Resources

The resources provisioned by this module are as follows:
- AWS ACM certificate for API URL
- AWS Route53 DNS record for API URL
  - This resource requires that an `ALB ARN` is provided
- AWS ALB Target Group
- AWS ALB Listener
  - This resource requires that an `ALB ARN` is provided
- AWS ECS Task Definition to ensure the Task Definition exists during deployment
- AWS ECS Service to ensure the Service exists during deployment
  - This resource requires that an `ASG Name` is provided