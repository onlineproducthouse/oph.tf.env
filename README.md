# onlineproducthouse.com Cloud Platform Infrastructure

Terraform code for managing onlineproducthouse.com's cloud resources using Infrastructure As Code (IAC)

## Getting started

To work with this codebase, you need to have Terraform and your AWS credentials configured.

- To set up Terraform, [click here](https://learn.hashicorp.com/terraform/getting-started/install.html)
- [Terraform documentation for AWS](https://www.terraform.io/docs/providers/aws/index.html)
- [An Introduction to Terraform](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180)

## Initial setup

This involves working with the `state_store` folder. We only work on this folder once.

- Comment out the following code so we can create the S3 bucket for storing state and deploy

```terraform
# Terraform remote state
terraform {
  backend "s3" {
    bucket = "S3_BUCKET_NAME"
    key    = "STATE_KEY"
    region = "eu-west-1"

    dynamodb_table = "DYNAMODB_TABLE_NAME"
    encrypt        = true
  }
}
```

- Now, uncomment the above code so we can store the state for the state store and deploy
- In the event you wish to destroy the platform, this will have to be destroyed last and manually.

