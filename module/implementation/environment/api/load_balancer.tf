#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_lb_target_group" "api" {
  count = var.api.run == true ? 1 : 0

  name        = "${var.api.name}-lb-tg"
  target_type = "instance"
  vpc_id      = var.api.vpc_id

  protocol = "HTTP"
  port     = var.api.port

  health_check {
    enabled = true

    interval            = 30
    timeout             = 5
    matcher             = 200
    healthy_threshold   = 5
    unhealthy_threshold = 5

    protocol = "HTTP"
    port     = var.api.port
    path     = var.api.load_balancer.health_check_path
  }
}

resource "aws_lb_listener" "api" {
  count = var.api.run == true ? 1 : 0

  load_balancer_arn = var.api.load_balancer.arn

  protocol = "HTTPS"
  port     = var.api.port

  ssl_policy      = "ELBSecurityPolicy-2016-08"
  certificate_arn = var.api.load_balancer.listener.certificate.arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.api[0].arn
  }
}

resource "aws_route53_record" "api" {
  count = var.api.run == true ? 1 : 0

  zone_id = var.api.load_balancer.hosted_zone.id
  name    = var.api.load_balancer.listener.certificate.domain_name
  type    = "A"

  alias {
    name                   = var.api.load_balancer.dns_name
    zone_id                = var.api.load_balancer.zone_id
    evaluate_target_health = true
  }
}

resource "aws_autoscaling_attachment" "api" {
  autoscaling_group_name = var.api.aws_autoscaling_group.name
  lb_target_group_arn    = aws_lb_target_group.api[0].arn
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  lb_output = {
    domain_name = var.api.load_balancer.listener.certificate.domain_name

    target_group = var.api.run == true ? {
      arn = aws_lb_target_group.api[0].arn
      } : {
      arn = ""
    }
  }
}
