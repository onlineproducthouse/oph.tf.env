provider "aws" {
  region = "us-east-1"
}

module "env" {
  source = "./.."

  for_each = {
    for v in local.env : v.name => v
  }

  config   = each.value.config
  network  = each.value.network
  platform = each.value.platform
  project  = each.value.project
}

locals {
  root_domain = {
    example = "example.org"
  }

  domain = {
    example = {
      test = "test.${local.root_domain.example}"
      qa   = "qa.${local.root_domain.example}"
      prod = local.root_domain.example
    }
  }

  env = [
    {
      name = "test"

      config = {
        variables = [
          { path = "/path/to/ssm/parameter", key : "ENVIRONMENT_NAME", value : "test" },
        ]
      }

      network = [
        {
          name              = "example"
          availability_zone = ["us-east-1a", "us-east-1b"]

          vpc_cidr_block            = "10.0.0.0/16"
          subnet_cidr_block_private = ["10.0.50.0/24", "10.0.51.0/24"]
          subnet_cidr_block_public  = ["10.0.0.0/24", "10.0.1.0/24"]

          alb_domain_name_alias         = local.domain.example.test
          alb_domain_name_alias_zone_id = "zone_id"

          alb_sg_rule = [
            { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], port = 0 },
            { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = 3000 },
          ]

          alb_target_groups = [
            {
              id                    = "api1",
              name                  = "api1",
              domain_name           = local.domain.example.test,
              port                  = "8080",
              acm_certificate_arn   = "arn:aws:acm:us-east-1:012345678901:certificate/7e7a28d2-163f-4b8f-b9cd-822f96c08d6a",
              alb_health_check_path = "/ping",
            },
            {
              id                    = "api2",
              name                  = "api2",
              domain_name           = local.domain.example.test,
              port                  = "8090",
              acm_certificate_arn   = "arn:aws:acm:us-east-1:012345678901:certificate/7e7a28d2-163f-4b8f-b9cd-822f96c08d6a",
              alb_health_check_path = "/ping",
            },
          ]

          sb_eip         = true
          sb_nat_gateway = true
          sb_alb         = true
        },
      ]

      platform = [
        {
          name         = "app"
          network_name = "example"

          fs_cors_origins = ["localhost:3000"]

          ec2_image_id      = "ami-0ef8272297113026d"
          ec2_instance_type = "t3a.nano"

          asg_min     = 2
          asg_max     = 3
          asg_desired = 2

          log_group_name     = "logs"
          log_stream_prefix  = "app"
          log_retention_days = 1

          sb_compute = true
          sb_storage = true
        },
        {
          name         = "batch"
          network_name = "example"

          fs_cors_origins = ["localhost:3000"]

          ec2_image_id      = "ami-0ef8272297113026d"
          ec2_instance_type = "t3a.micro"

          asg_min     = 1
          asg_max     = 1
          asg_desired = 1

          log_group_name     = "logs"
          log_stream_prefix  = "batch"
          log_retention_days = 1

          alb_target_groups     = []
          alb_security_group_id = ""

          sb_compute = true
          sb_storage = false
        },
      ]

      project = {
        api = [
          {
            network_name  = "example"
            platform_name = "app"

            name   = "api"
            region = "us-east-1"

            port                = 3000
            domain_name         = "api.${local.domain.example.test}"
            alb_target_group_id = "api1"

            task_cpu    = 450
            task_memory = 1800
            task_image  = "redis:latest"

            ecs_svc_desired_tasks_count = "1"
            ecs_svc_min_health_perc     = 100
            ecs_svc_max_health_perc     = 200
          },
        ]

        batch = [
          {
            network_name  = "example"
            platform_name = "batch"

            name   = "proc"
            region = "us-east-1"

            task_cpu    = 900
            task_memory = 1800
            task_image  = "redis:latest"

            ecs_svc_desired_tasks_count = "1"
            ecs_svc_min_health_perc     = 100
            ecs_svc_max_health_perc     = 200
          },
        ]

        web = [
          {
            name                = "www"
            hosted_zone_id      = "Z1PA6795UKMFR9"
            acm_certificate_arn = "arn:aws:acm:us-east-1:012345678901:certificate/7e7a28d2-163f-4b8f-b9cd-822f96c08d6a"
            domain_name         = "www.${local.domain.example.test}"
            index_page          = "index.html"
            error_page          = "error.html"
          },
          {
            name                = "blog"
            hosted_zone_id      = "Z1PA6795UKMFR9"
            acm_certificate_arn = "arn:aws:acm:us-east-1:012345678901:certificate/7e7a28d2-163f-4b8f-b9cd-822f96c08d6a"
            domain_name         = "blog.${local.domain.example.test}"
            index_page          = "index.html"
            error_page          = "error.html"
          },
        ]
      }
    },
  ]
}
