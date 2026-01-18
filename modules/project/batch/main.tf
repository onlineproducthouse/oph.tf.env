resource "aws_ecs_task_definition" "task" {
  family                   = var.name
  task_role_arn            = var.cluster_role_arn
  execution_role_arn       = var.cluster_role_arn
  network_mode             = "host"
  requires_compatibilities = ["EC2"]
  cpu                      = var.task_cpu
  memory                   = var.task_memory

  container_definitions = jsonencode([
    {
      "name" : "${var.name}",
      "image" : "${var.task_image}",
      "cpu" : "${var.task_cpu}",
      "memory" : "${var.task_memory}",
      "essential" : true,
      "logConfiguration" : {
        "logDriver" : "awslogs",
        "options" : {
          "awslogs-group" : "${var.cw_log_group}",
          "awslogs-region" : "${var.region}",
          "awslogs-stream-prefix" : "ecs"
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
          "value" : "${var.name}"
        },
      ]
    }
  ])
}

resource "aws_ecs_service" "service" {
  count = var.asg_name == "" ? 0 : 1

  name                    = var.name
  cluster                 = var.cluster_id
  scheduling_strategy     = "REPLICA"
  enable_ecs_managed_tags = true
  # iam_role                = var.cluster_role_arn

  task_definition                    = aws_ecs_task_definition.task.arn
  desired_count                      = var.ecs_svc_desired_tasks_count
  deployment_minimum_healthy_percent = var.ecs_svc_min_health_perc
  deployment_maximum_percent         = var.ecs_svc_max_health_perc

  lifecycle {
    ignore_changes = [task_definition]
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  capacity_provider_strategy {
    capacity_provider = var.asg_name
    weight            = 1
    base              = 1
  }
}
