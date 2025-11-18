module "env" {
  source = "./.."

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
        domain_name           = "api.example.org"
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
        domain_name    = "www.example.org"
        index_page     = "index.html"
        error_page     = "error.html"
      },
      {
        name           = "blog"
        hosted_zone_id = "Z1PA6795UKMFR9"
        domain_name    = "blog.example.org"
        index_page     = "index.html"
        error_page     = "error.html"
      },
    ]
  }
}
