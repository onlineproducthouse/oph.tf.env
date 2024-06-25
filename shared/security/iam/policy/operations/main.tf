#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/operations/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "oph-cloud-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

locals {
  operations = [
    { name = "business", description = "oph policy for business", policy = local.policy.business },
    { name = "compute_ec2", description = "oph policy for compute_ec2", policy = local.policy.compute_ec2 },
    { name = "compute_autoscaling", description = "oph policy for compute_autoscaling", policy = local.policy.compute_autoscaling },
    { name = "compute_elasticloadbalancing", description = "oph policy for compute_elasticloadbalancing", policy = local.policy.compute_elasticloadbalancing },
    { name = "container", description = "oph policy for container", policy = local.policy.container },
    { name = "database", description = "oph policy for database", policy = local.policy.database },
    { name = "developer_tools", description = "oph policy for developer tools", policy = local.policy.developer_tools },
    { name = "monitoring", description = "oph policy for monitoring", policy = local.policy.monitoring },
    { name = "networking", description = "oph policy for networking", policy = local.policy.networking },
    { name = "security", description = "oph policy for security", policy = local.policy.security },
    { name = "storage", description = "oph policy for storage", policy = local.policy.storage },
  ]
}

resource "aws_iam_policy" "operations" {
  for_each = {
    for index, operation in local.operations : operation.name => operation
  }

  name        = each.value.name
  path        = "/oph/"
  description = each.value.description
  policy      = jsonencode(each.value.policy)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "operations" {
  value = {
    for index, operation in local.operations : operation.name => {
      arn    = aws_iam_policy.operations[operation.name].arn
      policy = local.policy[operation.name]
    }
  }
}
