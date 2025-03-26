terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.70.0"
    }
  }
}

data "terraform_remote_state" "client" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/iam/terraform.tfstate"
    region = "eu-west-1"
  }
}

provider "aws" {
  profile = "default"
  region  = var.client_info.region

  assume_role {
    role_arn = data.terraform_remote_state.client.outputs.role_arn.for_oph_entities
  }

  default_tags {
    tags = {
      project_name           = var.client_info.project_name
      project_short_name     = var.client_info.project_short_name
      service_name           = var.client_info.service_name
      service_short_name     = var.client_info.service_short_name
      environment_name       = var.client_info.environment_name
      environment_short_name = var.client_info.environment_short_name
    }
  }
}
