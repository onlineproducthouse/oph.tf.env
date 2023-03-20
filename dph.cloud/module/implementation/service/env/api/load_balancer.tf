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
  load_balancer = {
    full_domain_name = "${var.api.load_balancer.domain_name_prefix}.${var.api.load_balancer.listener.certificate.domain_name}"
  }
}

resource "aws_security_group" "lb" {
  count = length(module.public_subnet) > 0 ? 1 : 0

  name   = "${var.api.name}-lb-sg"
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
  lb_sg_rules = [
    { name = "public", type = "egress", protocol = "-1", cidr_blocks = ["0.0.0.0/0"], port = 0 },
    { name = "api", type = "ingress", protocol = "tcp", cidr_blocks = ["0.0.0.0/0"], port = var.api.port },
  ]
}

resource "aws_security_group_rule" "lb" {
  for_each = {
    for index, rule in local.lb_sg_rules : rule.name => rule
  }

  security_group_id = aws_security_group.lb[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_lb" "lb" {
  count = length(aws_security_group.lb) > 0 ? 1 : 0

  name               = "${var.api.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb[0].id]
  subnets            = module.public_subnet[0].id_list

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_lb_target_group" "lb" {
  count = length(aws_lb.lb) > 0 ? 1 : 0

  name        = "${var.api.name}-lb-tg"
  target_type = "ip"
  vpc_id      = aws_vpc.api[0].id

  protocol = "HTTP"
  port     = var.api.port

  health_check {
    enabled = true

    interval            = 30
    timeout             = 15
    matcher             = 200
    healthy_threshold   = 3
    unhealthy_threshold = 3

    protocol = "HTTP"
    port     = var.api.port
    path     = var.api.load_balancer.health_check_path
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_lb_listener" "api" {
  count = length(aws_lb.lb) > 0 ? 1 : 0

  load_balancer_arn = aws_lb.lb[0].arn

  protocol = "HTTPS"
  port     = var.api.port

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.api.load_balancer.listener.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb[0].arn
  }
}

resource "aws_route53_record" "record_with_alias" {
  count = length(aws_lb.lb) > 0 ? 1 : 0

  zone_id = var.api.load_balancer.hosted_zone.id
  name    = local.load_balancer.full_domain_name
  type    = "A"

  alias {
    name                   = aws_lb.lb[0].dns_name
    zone_id                = aws_lb.lb[0].zone_id
    evaluate_target_health = true
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  lb_output = var.api.network.in_use == true ? {
    domain_name = local.load_balancer.full_domain_name

    target_group = {
      arn = aws_lb_target_group.lb[0].arn
    }
    } : {
    domain_name = ""

    target_group = {
      arn = ""
    }
  }
}
