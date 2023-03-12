#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/developer_tools/scripts/terraform.tfstate"
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
  region = "eu-west-1"
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

data "terraform_remote_state" "developer_tools" {
  backend = "s3"

  config = {
    bucket = "dph-platform-terraform-remote-state"
    key    = "shared/ci/storage/developer_tools/terraform.tfstate"
    region = "eu-west-1"
  }
}

module "load_environment_variables" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/load-env-vars.sh"
  source_path = "./scripts/load-env-vars.sh"
}

module "local_environment_variables" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/local-env-vars.sh"
  source_path = "./scripts/local-env-vars.sh"
}

module "build_container" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/build-container.sh"
  source_path = "./scripts/build-container.sh"
}

module "build_client" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/build-client.sh"
  source_path = "./scripts/build-client.sh"
}

module "buildspec" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/codebuild.job.yml"
  source_path = "./scripts/codebuild.job.yml"
}

module "deploy_container" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/deploy-container.sh"
  source_path = "./scripts/deploy-container.sh"
}

module "deploy_client" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/deploy-client.sh"
  source_path = "./scripts/deploy-client.sh"
}

module "cloudfront_invalidate" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/cf-invalidate.js"
  source_path = "./scripts/cf-invalidate.js"
}

module "migrate_db" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/migrate-db.sh"
  source_path = "./scripts/migrate-db.sh"
}

module "product_platform_state" {
  source = "../../../../module/interface/aws/storage/s3/bucket/object"

  bucket_id   = data.terraform_remote_state.developer_tools.outputs.id
  key         = "/dph/scripts/product.platform.state.sh"
  source_path = "./scripts/product.platform.state.sh"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "local_environment_variables_key" {
  value = module.local_environment_variables.key
}

output "load_environment_variables_key" {
  value = module.load_environment_variables.key
}

output "build_container_key" {
  value = module.build_container.key
}

output "build_client_key" {
  value = module.build_client.key
}

output "buildspec_key" {
  value = module.buildspec.key
}

output "cloudfront_invalidate_key" {
  value = module.cloudfront_invalidate.key
}

output "migrate_db_key" {
  value = module.migrate_db.key
}
