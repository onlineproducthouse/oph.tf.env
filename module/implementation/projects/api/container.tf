#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  task_definition_family = "${var.api.name}-task"
  port_mapping_name      = "${var.api.name}-port"
  service_name           = "${var.api.name}-svc"
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "api" {
  count = var.api.run == true && length(aws_lb_target_group.api) > 0 ? 1 : 0

  family                   = local.task_definition_family
  task_role_arn            = var.api.container.role_arn
  execution_role_arn       = var.api.container.role_arn
  network_mode             = var.api.container.network_mode
  requires_compatibilities = [var.api.container.launch_type]
  cpu                      = var.api.container.cpu
  memory                   = var.api.container.memory

  container_definitions = jsonencode([
    {
      "name" : "${var.api.container.name}",
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.api.region}.amazonaws.com/oph-comingsoon:latest",
      "cpu" : "${var.api.container.cpu}",
      "memory" : "${var.api.container.memory}",
      "essential" : true,
      "portMappings" : [
        {
          "name" : "${local.port_mapping_name}",
          "protocol" : "tcp",
          "containerPort" : "${var.api.port}",
          "hostPort" : "${var.api.port}"
        }
      ],
      "logConfiguration" : {
        "logDriver" : "${var.api.container.logging.driver}",
        "options" : {
          "awslogs-group" : "${var.api.container.logging.group}",
          "awslogs-region" : "${var.api.region}",
          "awslogs-stream-prefix" : "${var.api.container.logging.prefix}"
        }
      },
      "environment" : [
        {
          "name" : "COMINGSOON_PROTOCOL",
          "value" : "https"
        },
        {
          "name" : "COMINGSOON_HOST",
          "value" : "${var.api.load_balancer.listener.certificate.domain_name}"
        },
        {
          "name" : "COMINGSOON_PORT",
          "value" : "${tostring(var.api.port)}"
        },
      ]
    }
  ])
}

resource "aws_ecs_service" "api" {
  count = var.api.run == true && length(aws_ecs_task_definition.api) > 0 ? 1 : 0

  name                    = local.service_name
  cluster                 = var.api.container.cluster_id
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true
  iam_role                = var.api.container.role_arn

  task_definition                    = aws_ecs_task_definition.api[0].arn
  desired_count                      = var.api.container.desired_tasks_count
  deployment_minimum_healthy_percent = var.api.container.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.api.container.deployment_maximum_healthy_percent

  lifecycle {
    ignore_changes = [task_definition]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.api[0].arn
    container_name   = var.api.container.name
    container_port   = var.api.port
  }

  capacity_provider_strategy {
    capacity_provider = var.api.aws_autoscaling_group.name
    weight            = 1
    base              = 1
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  container_output = {
    container_name = var.api.container.name
    service_name   = local.service_name
    cpu            = var.api.container.cpu
    memory         = var.api.container.memory
    network_mode   = var.api.container.network_mode

    port_mapping_name = local.port_mapping_name
    port              = var.api.port

    task_definition_family = local.task_definition_family
    task_role_arn          = var.api.container.role_arn
    logging                = var.api.container.logging
  }
}
