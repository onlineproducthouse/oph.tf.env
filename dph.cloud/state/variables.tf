variable "region" {
  type    = string
  default = "eu-west-1"
}

variable "owner" {
  type    = string
  default = ""
}

variable "project_name" {
  type        = string
  default     = ""
  description = "The name of the project this resource is being created for"
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
