# OPH Environment Terraform Modules - Project - API

This module provisions infrastructure required for hosting an API

![diagram](../../../assets/oph.tf.env.container.png)

## Dependencies

This module assumes the [network](../../network/README.md) and [platform](../../platform/README.md) modules are provisioned.

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