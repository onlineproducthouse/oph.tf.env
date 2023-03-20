#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cluster" {
  type = object({
    name                      = string
    enable_container_insights = bool

    service = object({
      launch_type                        = string
      desired_tasks_count                = number
      target_capacity                    = number
      deployment_minimum_healthy_percent = number
      deployment_maximum_healthy_percent = number

      container = object({
        name               = string
        cpu                = number
        memory_reservation = number
      })
    })
  })

  default = {
    enable_container_insights = false
    name                      = "UnknownCluster"
    service = {
      launch_type = "FARGATE"

      desired_tasks_count                = 0
      target_capacity                    = 100
      deployment_minimum_healthy_percent = 0
      deployment_maximum_healthy_percent = 0

      container = {
        cpu                = 1
        memory_reservation = 1
        name               = ""
      }
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  shared_resource_name = "${var.client_info.project_short_name}-${var.client_info.service_name}-${var.client_info.environment_name}"
}

locals {
  container = var.network.vpc_in_use == false ? {
    cluster_name           = ""
    service_name           = ""
    task_definition_family = ""
    task_role_arn          = ""

    port_mapping_name = "${local.shared_resource_name}-port"

    container_name               = ""
    container_cpu                = 1
    container_memory_reservation = 1
    container_port               = -1

    logging = {
      driver = "awslogs"
      prefix = "${var.client_info.project_short_name}ecs"
      group  = "/${var.client_info.project_short_name}ecs/${local.shared_resource_name}/${var.cluster.service.container.name}"
    }

    security_group_id              = ""
    security_group_rule_id         = ""
    security_group_ingress_rule_id = ""
    } : {
    cluster_name           = module.cluster[0].name
    service_name           = "${local.shared_resource_name}-service"
    task_definition_family = "${local.shared_resource_name}-task-family"
    task_role_arn          = aws_iam_role.container_role.arn

    port_mapping_name = "${local.shared_resource_name}-port"

    container_name               = var.cluster.service.container.name
    container_cpu                = var.cluster.service.container.cpu
    container_memory_reservation = var.cluster.service.container.memory_reservation
    container_port               = var.port

    logging = {
      driver = "awslogs"
      prefix = "${var.client_info.project_short_name}ecs"
      group  = "/${var.client_info.project_short_name}ecs/${local.shared_resource_name}/${var.cluster.service.container.name}"
    }

    security_group_id              = aws_security_group.container_sg[0].id
    security_group_rule_id         = aws_security_group_rule.container_sg_rule[0].id
    security_group_ingress_rule_id = aws_security_group_rule.container_sg_ingress_rule["app"].id
  }
}

resource "aws_security_group" "container_sg" {
  count = var.network.vpc_in_use == false ? 0 : 1

  name   = "${var.cluster.name}-sg"
  vpc_id = local.network.vpc_id

  lifecycle {
    create_before_destroy = false
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_security_group_rule" "container_sg_rule" {
  count = length(aws_security_group.container_sg) > 0 ? 1 : 0

  security_group_id = aws_security_group.container_sg[0].id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
}

locals {
  ingress_rules = [
    { name = "app", port = var.port },
    { name = "unsecure", port = 80 },
    { name = "secure", port = 443 },
  ]
}

resource "aws_security_group_rule" "container_sg_ingress_rule" {
  # count = length(aws_security_group.container_sg) > 0 ? 1 : 0

  for_each = length(aws_security_group.container_sg) <= 0 ? {} : {
    for index, rule in local.ingress_rules : rule.name => rule
  }

  security_group_id = aws_security_group.container_sg[0].id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # for this environment, investigate using VPN
  from_port         = each.value.port
  to_port           = each.value.port
}

module "cluster" {
  source = "../../../../../module/interface/aws/containers/ecs/cluster"

  count = length(aws_security_group.container_sg) > 0 ? 1 : 0

  client_info = var.client_info
  cluster = {
    name                      = var.cluster.name
    enable_container_insights = var.cluster.enable_container_insights
  }
}

resource "aws_ecs_service" "service" {
  count = length(module.cluster) > 0 ? 1 : 0

  name    = local.container.service_name
  cluster = module.cluster[0].id
  # iam_role                = aws_iam_role.container_role.arn
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true

  task_definition                    = aws_ecs_task_definition.starter_app[0].arn
  desired_count                      = var.cluster.service.desired_tasks_count
  deployment_minimum_healthy_percent = var.cluster.service.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.cluster.service.deployment_maximum_healthy_percent

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.load_balancer_target_group[0].arn
    container_name   = local.container.container_name
    container_port   = local.container.container_port
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  network_configuration {
    subnets         = module.private_subnet[0].id_list
    security_groups = [aws_security_group.container_sg[0].id]
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_cp" {
  count = length(module.cluster) > 0 ? 1 : 0

  cluster_name = module.cluster[0].name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

resource "aws_cloudwatch_log_group" "container_log_group" {
  name              = local.container.logging.group
  retention_in_days = 30

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_ecs_task_definition" "starter_app" {
  count = length(module.cluster) > 0 ? 1 : 0

  family                   = local.container.task_definition_family
  task_role_arn            = aws_iam_role.container_role.arn
  execution_role_arn       = aws_iam_role.container_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = [var.cluster.service.launch_type]
  cpu                      = local.container.container_cpu
  memory                   = local.container.container_memory_reservation

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "${local.container.container_name}",
      "image" : "httpd:2.4",
      "cpu" : "${local.container.container_cpu}",
      "memory" : "${local.container.container_memory_reservation}",
      "essential" : true,
      "command" : [
        "/bin/sh -c \"echo '<html> <head> <title>DPH Sample App</title> <style>body {margin-top: 40px; background-color: #002050;} </style> </head><body> <div style=color:#eceae0;text-align:center> <h1>DPH Sample App</h1> <h2>Congratulations!</h2> <p>Your container application running in Amazon ECS is ready for deployment.</p> </div><div><p>Built by digitalproducthaus.com</p></div></body></html>' >  /usr/local/apache2/htdocs/index.html\""
      ],
      "entryPoint" : [
        "sh",
        "-c"
      ],
      "portMappings" : [
        {
          "name" : "${local.container.port_mapping_name}",
          "protocol" : "tcp",
          "containerPort" : "${local.container.container_port}",
          "hostPort" : "${local.container.container_port}"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "${local.container.logging.driver}",
        "options" : {
          "awslogs-group" : "${local.container.logging.group}",
          "awslogs-region" : "${var.client_info.region}",
          "awslogs-stream-prefix" : "${local.container.logging.prefix}"
        }
      }
    }
  ])
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ecs" {
  value = {
    container = local.container
  }
}
