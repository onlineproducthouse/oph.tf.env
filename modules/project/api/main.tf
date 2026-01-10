#region URL

resource "aws_acm_certificate" "acm" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route53_record" "acm" {
  for_each = {
    for dvo in aws_acm_certificate.acm.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    } if contains(split("", dvo.domain_name), "*") != true
  }

  zone_id = var.hosted_zone_id
  name    = each.value.name
  type    = each.value.type
  ttl     = "60"
  records = [each.value.record]
}

resource "aws_acm_certificate_validation" "acm_cert_validation" {
  certificate_arn         = aws_acm_certificate.acm.arn
  validation_record_fqdns = [for item in aws_route53_record.acm : item.fqdn]
}

resource "aws_route53_record" "domain_name" {
  count = var.alb_available ? 1 : 0

  zone_id = var.hosted_zone_id
  name    = aws_acm_certificate.acm.domain_name
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_hosted_zone_id
    evaluate_target_health = true
  }
}

#endregion

#region Load Balancer

resource "aws_lb_target_group" "alb_tg" {
  name        = var.name
  target_type = "instance"
  vpc_id      = var.vpc_id

  protocol = "HTTP"
  port     = var.port

  health_check {
    enabled = true

    interval            = 30
    timeout             = 5
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5

    protocol = "HTTP"
    port     = var.port
    path     = var.alb_health_check_path
  }
}

resource "aws_lb_listener" "api" {
  count = var.alb_available ? 1 : 0

  load_balancer_arn = var.alb_arn

  protocol = "HTTPS"
  port     = var.port

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = aws_acm_certificate.acm.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb_tg.arn
  }
}

resource "aws_autoscaling_attachment" "api" {
  count = var.asg_name == "" ? 0 : 1

  autoscaling_group_name = var.asg_name
  lb_target_group_arn    = aws_lb_target_group.alb_tg.arn
}

#endregion

#region Container Service

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
      "portMappings" : [
        {
          "name" : "${var.name}-port",
          "protocol" : "tcp",
          "containerPort" : "${var.port}",
          "hostPort" : "${var.port}"
        }
      ],
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
          "value" : "${aws_acm_certificate.acm.domain_name}"
        },
        {
          "name" : "COMINGSOON_PORT",
          "value" : "${tostring(var.port)}"
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
  iam_role                = var.cluster_role_arn

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

  load_balancer {
    target_group_arn = aws_lb_target_group.alb_tg.arn
    container_name   = var.name
    container_port   = var.port
  }

  capacity_provider_strategy {
    capacity_provider = var.asg_name
    weight            = 1
    base              = 1
  }
}

#endregion
