#####################################################
#                                                   #
#                        STATE                      #
#                                                   #
#####################################################

terraform {
  backend "s3" {
    bucket = "oph-cloud-terraform-remote-state"
    key    = "shared/tech_stack/terraform.tfstate"
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

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "tech_stack" {
  value = {
    business = ["GSuite", "Jira", "Confluence", "draw.io", "Quickbooks"]

    thirdparty = ["Cloudinary", "RedisLabs", "SendGrid", "ScaleGrid", "Paystack", "Twilio"]

    frontend = {
      languages  = ["html", "css", "javascript"]
      frameworks = ["bootstrap", "vue", "storybook", "react", "angular"]
    }

    backend = {
      languages  = ["go", "c#", "nodejs", "php", "python"]
      frameworks = ["fibre", "echo", "dotnetcore", "express"]
      databases  = ["postgres", "mssql", "mysql", "redis", "mongo", "cassandra", "dynamodb"]
      messaging  = ["AWS SQS", "Rabbit MQ", "Kafka"]
    }

    devops = {
      container      = ["Docker", "ECR", "ECS", "Docker swarm", "Kubernetes"]
      storage        = ["AWS S3", "Sharepoint"]
      infrastructure = ["Afrihost", "AWS", "Azure", "Heroku"]
      scm            = ["bitbucket"]

      os = ["linux", "windows", "mac"]

      cloud = {
        aws = [
          "IAM",
          "S3",
          "SSM",
          "ACM",
          "Route53",
          "VPC",
          "CodeStar",
          "CodeBuild",
          "CodePipeline",
          "DynamoDB",
          "ECR",
          "ECS",
          "ALB",
          "EC2",
          "ASG",
          "CloudWatch",
          "SQS",
          "SNS",
          "SES",
          "CloudFront",
        ]
      }
    }
  }
}
