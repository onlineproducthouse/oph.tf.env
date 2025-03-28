#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  task_definition_family = "${var.batch.name}-task"
  service_name           = "${var.batch.name}-svc"
}

data "aws_caller_identity" "current" {}

resource "aws_ecs_task_definition" "api" {
  family                   = local.task_definition_family
  task_role_arn            = var.batch.container.role_arn
  execution_role_arn       = var.batch.container.role_arn
  network_mode             = var.batch.container.network_mode
  requires_compatibilities = [var.batch.container.launch_type]
  cpu                      = var.batch.container.cpu
  memory                   = var.batch.container.memory

  container_definitions = jsonencode([
    {
      "name" : "${var.batch.container.name}",
      "image" : "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.batch.region}.amazonaws.com/oph-comingsoon:latest",
      "cpu" : "${var.batch.container.cpu}",
      "memory" : "${var.batch.container.memory}",
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "${var.batch.container.logging.driver}",
        "options" : {
          "awslogs-group" : "${var.batch.container.logging.group}",
          "awslogs-region" : "${var.batch.region}",
          "awslogs-stream-prefix" : "${var.batch.container.logging.prefix}"
        }
      },
      "environment" : [
        {
          "name" : "COMINGSOON_PROTOCOL",
          "value" : "https"
        },
        {
          "name" : "COMINGSOON_HOST",
          "value" : "example.org"
        },
        {
          "name" : "COMINGSOON_PORT",
          "value" : "80"
        },
        {
          "name" : "COMINGSOON_FOR_PROJECT",
          "value" : "${var.batch.name}"
        },
      ]
    }
  ])
}

resource "aws_ecs_service" "api" {
  count = var.batch.run == true ? 1 : 0

  name                    = local.service_name
  cluster                 = var.batch.container.cluster_id
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true
  iam_role                = var.batch.container.role_arn

  task_definition                    = aws_ecs_task_definition.api.arn
  desired_count                      = var.batch.container.desired_tasks_count
  deployment_minimum_healthy_percent = var.batch.container.deployment_minimum_healthy_percent
  deployment_maximum_percent         = var.batch.container.deployment_maximum_healthy_percent

  lifecycle {
    ignore_changes = [task_definition]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  capacity_provider_strategy {
    capacity_provider = var.batch.aws_autoscaling_group.name
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
    container_name = var.batch.container.name
    service_name   = local.service_name
    cpu            = var.batch.container.cpu
    memory         = var.batch.container.memory
    network_mode   = var.batch.container.network_mode

    task_definition_family = local.task_definition_family
    task_role_arn          = var.batch.container.role_arn
    logging                = var.batch.container.logging
  }
}
