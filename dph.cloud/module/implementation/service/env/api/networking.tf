#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "networking" {
  type = object({
    domain_name_prefix = string

    hosted_zone = object({
      id = string
    })

    load_balancer = object({
      subnet_id_list = list(string)
      listener = object({
        certificate = object({
          arn         = string
          domain_name = string
        })
      })
    })
  })
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "load_balancer_sg" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name   = "${var.compute.launch_configuration.name}-lb-sg"
  vpc_id = var.compute.vpc.id

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

resource "aws_security_group_rule" "load_balancer_sg_rule" {
  count = var.compute.vpc.id == "" ? 0 : 1

  security_group_id = aws_security_group.load_balancer_sg[0].id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "load_balancer_sg_ingress_rule" {
  count = var.compute.vpc.id == "" ? 0 : 1

  security_group_id = aws_security_group.load_balancer_sg[0].id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # for this environment, investigate using VPN
  from_port         = local.api.port
  to_port           = local.api.port
}

resource "aws_lb" "load_balancer" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name               = "${var.compute.launch_configuration.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = aws_security_group.load_balancer_sg
  subnets            = var.networking.load_balancer.subnet_id_list

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_lb_target_group" "load_balancer_target_group" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name        = "${var.compute.launch_configuration.name}-lb-tg"
  target_type = "instance"
  vpc_id      = var.compute.vpc.id

  protocol = "HTTP"
  port     = local.api.port

  health_check {
    enabled = true

    interval            = 30
    timeout             = 15
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3

    protocol = "HTTP"
    port     = local.api.port
    path     = "/api/v1/HealthCheck/Ping"
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_lb_listener" "listener" {
  count = var.compute.vpc.id == "" ? 0 : 1

  load_balancer_arn = aws_lb.load_balancer[0].arn

  protocol = "HTTPS"
  port     = local.api.port

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.networking.load_balancer.listener.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_target_group[0].arn
  }
}

resource "aws_route53_record" "record_with_alias" {
  count = var.compute.vpc.id == "" ? 0 : 1

  zone_id = var.networking.hosted_zone.id
  name    = "${var.networking.domain_name_prefix}.${var.networking.load_balancer.listener.certificate.domain_name}"
  type    = "A"

  alias {
    name                   = aws_lb.load_balancer[0].dns_name
    zone_id                = aws_lb.load_balancer[0].zone_id
    evaluate_target_health = true
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

