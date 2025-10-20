# OPH Environment Terraform Modules - Project - Batch

This module provisions infrastructure required for hosting a batch processing application.

## Dependencies

This module assumes the native network and platform modules, or something similar, is provisioned.

From the platform module, this module requires:
- ASG Name
- Cluster ID
- Cluster Role ARN
- CloudWatch Log Group

## Resources

The resources provisioned by this module are as follows:
- AWS ECS Task Definition to ensure the Task Definition exists during deployment
- AWS ECS Service to ensure the Service exists during deployment
  - This resource requires that an `ASG Name` is provided