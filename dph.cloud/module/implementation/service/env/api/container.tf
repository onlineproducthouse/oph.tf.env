#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################


#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  common = {
    cluster_name           = "${var.api.name}-cluster"
    task_definition_family = "${var.api.name}-task-family"
    container_name         = "${var.api.name}-container"
    service_name           = "${var.api.name}-service"
    port_mapping_name      = "${var.api.name}-port"

    logging = {
      driver = "awslogs"
      prefix = "ecs"
      group  = var.api.container.log_group
    }
  }
}

resource "aws_security_group" "container" {
  count = length(module.private_subnet) > 0 ? 1 : 0

  name   = "${local.common.container_name}-sg"
  vpc_id = aws_vpc.api[0].id

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

locals {
  container_sg_rules = [
    { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], port = 0 },
    { name = "unsecure", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = 80 },
    { name = "secure", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = 443 },
    { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = var.api.port },
  ]
}

resource "aws_security_group_rule" "container" {
  for_each = length(aws_security_group.container) <= 0 ? {} : {
    for index, rule in local.container_sg_rules : rule.name => rule
  }

  security_group_id = aws_security_group.container[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_cloudwatch_log_group" "container" {
  name              = local.common.logging.group
  retention_in_days = 30

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

module "cluster" {
  source = "../../../../../module/interface/aws/containers/ecs/cluster"

  count = length(aws_security_group.container) > 0 ? 1 : 0

  client_info = var.client_info
  cluster = {
    name                      = local.common.cluster_name
    enable_container_insights = var.api.container.enable_container_insights
  }
}

resource "aws_ecs_cluster_capacity_providers" "container" {
  count = length(module.cluster) > 0 ? 1 : 0

  cluster_name = module.cluster[0].name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

data "aws_caller_identity" "current" {}

locals {
  registry = {
    base_url = ""
  }
}

resource "aws_ecs_task_definition" "container" {
  count = length(module.cluster) > 0 ? 1 : 0

  family                   = local.common.task_definition_family
  task_role_arn            = aws_iam_role.api.arn
  execution_role_arn       = aws_iam_role.api.arn
  network_mode             = var.api.container.network_mode
  requires_compatibilities = [var.api.container.launch_type]
  cpu                      = var.api.container.cpu
  memory                   = var.api.container.memory

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      "name" : "${local.common.container_name}",
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.client_info.region}.amazonaws.com/httpd:2.4",
      "cpu" : "${var.api.container.cpu}",
      "memory" : "${var.api.container.memory}",
      "essential" : true,
      "command" : [
        "/bin/sh -c \"echo '<html> <head> <title>DPH Sample App</title> <style>body {margin-top: 40px; background-color: #002050;} </style> </head><body> <div style=color:#eceae0;text-align:center> <h1>DPH Sample App</h1> <h2>Congratulations!</h2> <p>Your container application running in Amazon ECS is ready for deployment.</p> </div><div><p>Built by digitalproducthaus.com</p></div></body></html>' >  /usr/local/apache2/htdocs/index.html && httpd-foreground\""
      ],
      "entryPoint" : [
        "sh",
        "-c"
      ],
      "portMappings" : [
        {
          "name" : "${local.common.port_mapping_name}",
          "protocol" : "tcp",
          "containerPort" : "${var.api.port}",
          "hostPort" : "${var.api.port}"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "${local.common.logging.driver}",
        "options" : {
          "awslogs-group" : "${local.common.logging.group}",
          "awslogs-region" : "${var.client_info.region}",
          "awslogs-stream-prefix" : "${local.common.logging.prefix}"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "container" {
  count = length(module.cluster) > 0 ? 1 : 0

  name                    = local.common.service_name
  cluster                 = module.cluster[0].id
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true
  # iam_role                = aws_iam_role.api.arn

  task_definition                    = aws_ecs_task_definition.container[0].arn
  desired_count                      = var.api.container.desired_tasks_count
  deployment_minimum_healthy_percent = var.api.container.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.api.container.deployment_maximum_healthy_percent

  lifecycle {
    ignore_changes = [desired_count, task_definition]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb[0].arn
    container_name   = local.common.container_name
    container_port   = var.api.port
  }

  capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }

  network_configuration {
    subnets         = module.private_subnet[0].id_list
    security_groups = [aws_security_group.container[0].id]
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  container_output = {
    cluster_name   = local.common.cluster_name
    service_name   = local.common.service_name
    container_name = local.common.container_name
    cpu            = var.api.container.cpu
    memory         = var.api.container.memory
    network_mode   = var.api.container.network_mode

    port_mapping_name = local.common.port_mapping_name
    port              = var.api.port

    task_definition_family = local.common.task_definition_family
    task_role_arn          = aws_iam_role.api.arn

    logging = {
      driver = local.common.logging.driver
      prefix = local.common.logging.prefix
      group  = local.common.logging.group
    }

    security_group = var.api.network.in_use == true ? {
      id              = aws_security_group.container[0].id
      egress_rule_id  = aws_security_group_rule.container["public"].id
      ingress_rule_id = aws_security_group_rule.container["api"].id
      } : {
      id              = ""
      egress_rule_id  = ""
      ingress_rule_id = ""
    }
  }
}
