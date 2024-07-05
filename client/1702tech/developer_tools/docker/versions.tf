terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }

    skopeo2 = {
      source  = "bsquare-corp/skopeo2"
      version = "~> 1.1.0"
    }
  }
}

data "aws_ecr_authorization_token" "ecr" {}

data "terraform_remote_state" "client" {
  backend = "s3"

  config = {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "client/1702tech/terraform.tfstate"
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

provider "skopeo2" {
  destination {
    login_username = data.aws_ecr_authorization_token.ecr.user_name
    login_password = data.aws_ecr_authorization_token.ecr.password
  }
}
