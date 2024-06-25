#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/security/iam/policy/developer/terraform.tfstate"
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

resource "aws_iam_policy" "developer" {
  name        = "developer"
  path        = "/oph/"
  description = "oph policy for developer"

  policy = local.policy
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "policy_arn" {
  value = aws_iam_policy.developer.arn
}

output "policy" {
  value = local.policy
}
