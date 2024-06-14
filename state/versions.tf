terraform {
  required_version = ">= 1.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.52.0"
    }
  }
}

provider "aws" {
  region = var.client_info.region

  default_tags {
    tags = {
      owner_name             = var.client_info.owner_name
      owner_short_name       = var.client_info.owner_short_name
      project_name           = var.client_info.project_name
      project_short_name     = var.client_info.project_short_name
      service_name           = var.client_info.service_name
      service_short_name     = var.client_info.service_short_name
      environment_name       = var.client_info.environment_name
      environment_short_name = var.client_info.environment_short_name
    }
  }
}
