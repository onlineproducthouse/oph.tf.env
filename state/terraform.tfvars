terraform_state_bucket_name               = "oph-cloud-terraform-remote-state"
terraform_state_locks_dynamodb_table_name = "oph-cloud-terraform-remote-state-locks"
dynamodb_table_billing_mode               = "PAY_PER_REQUEST"
dynamodb_hash_key                         = "LockID"

client_info = {
  region                 = "eu-west-1"
  owner_name             = "1702tech"
  owner_short_name       = "1702"
  project_name           = "onlineproducthouse.com"
  project_short_name     = "oph"
  service_name           = "state"
  service_short_name     = "state"
  environment_name       = "shared"
  environment_short_name = "shared"
}
