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
        fs_platform_name = ""
        ssm_param_path   = local.ssm_param_path

        variables = [
          { key : "ENVIRONMENT_NAME", value : "local" },

          # { key : "RUN_SWAGGER", value : "" }, # get from root module

          # { key : "DB_CONNECTION_STRING", value : "" }, # get from root module
          # { key : "DB_PROTOCOL", value : "" },          # get from root module
          # { key : "DB_USERNAME", value : "" },          # get from root module
          # { key : "DB_PASSWORD", value : "" },          # get from root module
          # { key : "DB_HOST", value : "" },              # get from root module
          # { key : "DB_PORT", value : "" },              # get from root module
          # { key : "DB_NAME", value : "" },              # get from root module

          # { key : "REDIS_CONNECTION_STRING", value : "" }, # get from root module
          # { key : "REDIS_HOST", value : "" },              # get from root module
          # { key : "REDIS_PORT", value : "" },              # get from root module
          # { key : "REDIS_PWD", value : "" },               # get from root module

          # { key : "SG_API_KEY", value : "" }, # get from root module

          # { key : "PAYSTACK_PUBLIC_KEY", value : "" }, # get from root module
          # { key : "PAYSTACK_SECRET_KEY", value : "" }, # get from root module

          # { key : "API_PROTOCOL", value : "" }, # get from root module
          # { key : "API_HOST", value : "" },     # get from root module
          # { key : "API_PORT", value : "" },     # get from root module
          # { key : "API_KEYS", value : "" },     # get from root module

          # { key : "WWW_APP_URL", value : "" },          # get from root module
          # { key : "PORTAL_APP_URL", value : "" },       # get from root module
          # { key : "CONSOLE_APP_URL", value : "" },      # get from root module
          # { key : "REGISTRATION_APP_URL", value : "" }, # get from root module

          # { key : "VITE_APP_CLIENT_API_KEY", value : "" },         # get from root module
          # { key : "VITE_APP_CLIENT_API_PROTOCOL", value : "" },    # get from root module
          # { key : "VITE_APP_CLIENT_WS_API_PROTOCOL", value : "" }, # get from root module
          # { key : "VITE_APP_CLIENT_API_HOST", value : "" },        # get from root module
          # { key : "VITE_APP_CLIENT_API_PORT", value : "" },        # get from root module
          # { key : "VITE_APP_CLIENT_API_BASE_PATH", value : "" },   # get from root module

          # { key : "VITE_APP_WEB_APP_PORTAL_URL", value : "" },       # get from root module
          # { key : "VITE_APP_WEB_APP_REGISTRATION_URL", value : "" }, # get from root module
          # { key : "VITE_APP_WEB_APP_CONSOLE_URL", value : "" },      # get from root module
        ]
      }

      network  = []
      platform = []

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
