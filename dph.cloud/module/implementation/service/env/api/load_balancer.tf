#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "load_balancer" {
  type = object({
    domain_name_prefix = string

    hosted_zone = object({
      id = string
    })

    listener = object({
      certificate = object({
        arn         = string
        domain_name = string
      })
    })
  })
}

locals {
  load_balancer = {
    full_domain_name = "${var.load_balancer.domain_name_prefix}.${var.load_balancer.listener.certificate.domain_name}"
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "load_balancer_sg" {
  count = length(aws_vpc.vpc) > 0 ? 1 : 0

  name   = "${var.compute.launch_configuration.name}-lb-sg"
  vpc_id = aws_vpc.vpc[0].id

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
  count = length(aws_security_group.load_balancer_sg) > 0 ? 1 : 0

  security_group_id = aws_security_group.load_balancer_sg[0].id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "load_balancer_sg_ingress_rule" {
  count = length(aws_security_group.load_balancer_sg) > 0 ? 1 : 0

  security_group_id = aws_security_group.load_balancer_sg[0].id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # for this environment, investigate using VPN
  from_port         = var.port
  to_port           = var.port
}

resource "aws_lb" "load_balancer" {
  count = length(aws_security_group.load_balancer_sg) > 0 && length(module.public_subnet) > 0 ? 1 : 0

  name               = "${var.compute.launch_configuration.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer_sg[0].id]
  subnets            = module.public_subnet[0].id_list

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_lb_target_group" "load_balancer_target_group" {
  count = length(aws_vpc.vpc) > 0 ? 1 : 0

  name        = "${var.compute.launch_configuration.name}-lb-tg"
  target_type = "instance"
  vpc_id      = aws_vpc.vpc[0].id

  protocol = "HTTP"
  port     = var.port

  health_check {
    enabled = true

    interval            = 30
    timeout             = 15
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3

    protocol = "HTTP"
    port     = var.port
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
  count = length(aws_lb.load_balancer) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.load_balancer[0].arn

  protocol = "HTTPS"
  port     = var.port

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.load_balancer.listener.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_target_group[0].arn
  }
}

resource "aws_route53_record" "record_with_alias" {
  count = length(aws_lb.load_balancer) > 0 ? 1 : 0

  zone_id = var.load_balancer.hosted_zone.id
  name    = local.load_balancer.full_domain_name
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

output "load_balancer" {
  value = {
    domain_name = local.load_balancer.full_domain_name
    target_group = length(aws_vpc.vpc) > 0 ? {
      arn = aws_lb_target_group.load_balancer_target_group[0].arn
      } : {
      arn = ""
    }
  }
}
