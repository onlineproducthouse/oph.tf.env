# Terraform remote state
terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "state_store/terraform.tfstate"
    region = "eu-west-1"

    dynamodb_table = "dph-platform-terraform-remote-state-locks"
    encrypt        = true
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.terraform_state_bucket_name

  tags = {
    owner        = var.owner
    project_name = var.project_name
  }
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

  tags = {
    owner        = var.owner
    project_name = var.project_name
  }
}
