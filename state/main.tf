#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "state/terraform.tfstate"
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

    owner_name       = string
    owner_short_name = string

    project_name       = string
    project_short_name = string

    service_name       = string
    service_short_name = string

    environment_name       = string
    environment_short_name = string
  })
}

variable "terraform_state_bucket_name" {
  type        = string
  default     = ""
  description = "Name of the AWS S3 bucket to store Terraform state in"
}

variable "terraform_state_locks_dynamodb_table_name" {
  type        = string
  default     = ""
  description = "Name of the AWS DynamoDB table used to lock state during plan/apply stages"
}

variable "dynamodb_table_billing_mode" {
  type        = string
  default     = ""
  description = "The billing mode AWS DynamoDB will use for the table"
}

variable "dynamodb_hash_key" {
  type        = string
  default     = ""
  description = "The hash key used by AWS DynamoDB"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket_name
}

resource "aws_s3_bucket_versioning" "terraform_state_versioning" {
  bucket = aws_s3_bucket.terraform_state.bucket

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "tf_state_server_side_encryption_configuration" {
  bucket = aws_s3_bucket.terraform_state.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_dynamodb_table" "terraform_state_locks" {
  name         = var.terraform_state_locks_dynamodb_table_name
  billing_mode = var.dynamodb_table_billing_mode
  hash_key     = var.dynamodb_hash_key

  attribute {
    name = var.dynamodb_hash_key
    type = "S"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "terraform_state_bucket_arn" {
  value       = aws_s3_bucket.terraform_state.arn
  description = "The ARN of the S3 bucket"
}

output "dynamodb_table_name" {
  value       = aws_dynamodb_table.terraform_state_locks.name
  description = "The name of the DynamoDB table"
}
