#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/security/iam/policy/operations/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

#####################################################
#                                                   #
#                      VERSIONS                     #
#                                                   #
#####################################################

terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      version = "4.8.0"
      source  = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "region" {
  type    = string
  default = "eu-west-1"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "aws_caller_identity" "current" {}

resource "aws_iam_policy" "business" {
  name        = "business"
  path        = "/dph/"
  description = "dph policy for business"
  policy      = jsonencode(local.policy.business)
}

resource "aws_iam_policy" "compute_ec2" {
  name        = "compute_ec2"
  path        = "/dph/"
  description = "dph policy for compute_ec2"
  policy      = jsonencode(local.policy.compute_ec2)
}

resource "aws_iam_policy" "compute_autoscaling" {
  name        = "compute_autoscaling"
  path        = "/dph/"
  description = "dph policy for compute_autoscaling"
  policy      = jsonencode(local.policy.compute_autoscaling)
}

resource "aws_iam_policy" "compute_elasticloadbalancing" {
  name        = "compute_elasticloadbalancing"
  path        = "/dph/"
  description = "dph policy for compute_elasticloadbalancing"
  policy      = jsonencode(local.policy.compute_elasticloadbalancing)
}

resource "aws_iam_policy" "container" {
  name        = "container"
  path        = "/dph/"
  description = "dph policy for container"
  policy      = jsonencode(local.policy.container)
}

resource "aws_iam_policy" "database" {
  name        = "database"
  path        = "/dph/"
  description = "dph policy for database"
  policy      = jsonencode(local.policy.database)
}

resource "aws_iam_policy" "developer_tools" {
  name        = "developer_tools"
  path        = "/dph/"
  description = "dph policy for developer tools"
  policy      = jsonencode(local.policy.developer_tools)
}

resource "aws_iam_policy" "monitoring" {
  name        = "monitoring"
  path        = "/dph/"
  description = "dph policy for monitoring"
  policy      = jsonencode(local.policy.monitoring)
}

resource "aws_iam_policy" "networking" {
  name        = "networking"
  path        = "/dph/"
  description = "dph policy for networking"
  policy      = jsonencode(local.policy.networking)
}

resource "aws_iam_policy" "security" {
  name        = "security"
  path        = "/dph/"
  description = "dph policy for security"
  policy      = jsonencode(local.policy.security)
}

resource "aws_iam_policy" "storage" {
  name        = "storage"
  path        = "/dph/"
  description = "dph policy for storage"
  policy      = jsonencode(local.policy.storage)
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "business_policy_arn" {
  value = aws_iam_policy.business.arn
}

output "compute_ec2_policy_arn" {
  value = aws_iam_policy.compute_ec2.arn
}

output "compute_autoscaling_policy_arn" {
  value = aws_iam_policy.compute_autoscaling.arn
}

output "compute_elasticloadbalancing_policy_arn" {
  value = aws_iam_policy.compute_elasticloadbalancing.arn
}

output "container_policy_arn" {
  value = aws_iam_policy.container.arn
}

output "database_policy_arn" {
  value = aws_iam_policy.database.arn
}

output "monitoring_policy_arn" {
  value = aws_iam_policy.monitoring.arn
}

output "networking_policy_arn" {
  value = aws_iam_policy.networking.arn
}

output "security_policy_arn" {
  value = aws_iam_policy.security.arn
}

output "storage_policy_arn" {
  value = aws_iam_policy.storage.arn
}
