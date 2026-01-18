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
  ssm_param_path = "/path/to/params"

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
      name = "local"

      config = {
        fs_platform_name = "app-local"
        ssm_param_path   = "${local.ssm_param_path}/local"

        variables = [
          { key : "ENVIRONMENT_NAME", value : "local" },
        ]
      }

      network = []

      platform = [
        {
          name                  = "app-local"
          network_name          = ""
          cw_log_retention_days = 1
          ec2_image_id          = ""
          ec2_instance_type     = ""
          asg_min               = 0
          asg_max               = 0
          asg_desired           = 0

          cluster_sg_rule = []
          fs_cors_origins = ["localhost:3000"]

          sb_cloudwatch = false
          sb_iam        = false
          sb_compute    = false
        },
      ]

      project = {
        api   = []
        batch = []
        web   = []
      }
    },
    {
      name = "test"

      config = {
        fs_platform_name = "app"
        ssm_param_path   = local.ssm_param_path

        variables = [
          { key : "ENVIRONMENT_NAME", value : "test" },
        ]
      }

      network = [
        {
          name                      = "example"
          availability_zone         = ["us-east-1a", "us-east-1b"]
          vpc_cidr_block            = "10.0.0.0/16"
          subnet_cidr_block_private = ["10.0.50.0/24", "10.0.51.0/24"]
          subnet_cidr_block_public  = ["10.0.0.0/24", "10.0.1.0/24"]

          sb_eip         = true
          sb_nat_gateway = true
          sb_alb         = true

          alb_sg_rule = [
            { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], port = 0 },
            { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = 3000 },
          ]
        },
      ]

      platform = [
        {
          name                  = "app"
          network_name          = "example"
          cw_log_retention_days = 1
          ec2_image_id          = "ami-0ef8272297113026d"
          ec2_instance_type     = "t3a.nano"
          asg_min               = 2
          asg_max               = 3
          asg_desired           = 2

          fs_cors_origins = ["localhost:3000"]

          cluster_sg_rule = [
            {
              name        = "public",
              type        = "egress",
              protocol    = "-1",
              cidr_blocks = ["0.0.0.0/0"],
              from_port   = 0,
              to_port     = 0,
            },
            {
              name        = "api",
              type        = "ingress",
              protocol    = "tcp",
              cidr_blocks = ["10.0.0.0/24", "10.0.1.0/24"],
              from_port   = 3000,
              to_port     = 3000,
            },
          ]

          sb_cloudwatch = true
          sb_iam        = true
          sb_compute    = true
        },
        {
          name                  = "batch"
          network_name          = "example"
          cw_log_retention_days = 1
          ec2_image_id          = "ami-0ef8272297113026d"
          ec2_instance_type     = "t3a.micro"
          asg_min               = 1
          asg_max               = 1
          asg_desired           = 1

          fs_cors_origins = ["localhost:3000"]

          cluster_sg_rule = [
            {
              name        = "public",
              type        = "egress",
              protocol    = "-1",
              cidr_blocks = ["0.0.0.0/0"],
              from_port   = 0,
              to_port     = 0,
            },
          ]

          sb_cloudwatch = true
          sb_iam        = true
          sb_compute    = true
        },
      ]

      project = {
        api = [
          {
            name          = "api"
            network_name  = "example"
            platform_name = "app"
            region        = "us-east-1"

            hosted_zone_id        = "Z1PA6795UKMFR9"
            port                  = 3000
            domain_name           = "api.${local.domain.example.test}"
            alb_health_check_path = "/ping"

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
            name          = "proc"
            network_name  = "example"
            platform_name = "batch"
            region        = "us-east-1"

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
            name           = "www"
            hosted_zone_id = "Z1PA6795UKMFR9"
            domain_name    = "www.${local.domain.example.test}"
            index_page     = "index.html"
            error_page     = "error.html"
          },
          {
            name           = "blog"
            hosted_zone_id = "Z1PA6795UKMFR9"
            domain_name    = "blog.${local.domain.example.test}"
            index_page     = "index.html"
            error_page     = "error.html"
          },
        ]
      }
    },
  ]
}
