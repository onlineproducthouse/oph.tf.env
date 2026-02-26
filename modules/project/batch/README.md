# OPH Environment Terraform Modules - Project - Batch

This module provisions infrastructure required for hosting a batch processing application.

![diagram](../../../assets/oph.tf.env.container.png)

## Dependencies

This module assumes the [network](../../network/README.md) and [platform](../../platform/README.md) modules are provisioned.

## Resources

The resources provisioned by this module are as follows:
- AWS ECS Task Definition to ensure the Task Definition exists during deployment
- AWS ECS Service to ensure the Service exists during deployment
  - This resource requires that an `ASG Name` is provided