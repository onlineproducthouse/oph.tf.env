#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "load_balancer" {
  count = length(aws_vpc.environment) > 0 ? 1 : 0

  name   = "${local.shared_name}-lb-sg"
  vpc_id = aws_vpc.environment[0].id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "load_balancer" {
  for_each = length(aws_security_group.load_balancer) > 0 ? {
    for index, rule in var.environment.load_balancer.security_group_rules : rule.name => rule
  } : {}

  security_group_id = aws_security_group.load_balancer[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_lb" "environment" {
  count = local.network_output.in_use == true && length(aws_vpc.environment) > 0 ? 1 : 0

  name               = "${local.shared_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer[0].id]
  subnets            = module.public_subnet[0].id_list

  access_logs {
    enabled = true
    bucket  = local.storage_output.storage.id
    prefix  = "${local.shared_name}-lb"
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  null_load_balancer_output = {
    arn      = ""
    dns_name = ""
    zone_id  = ""
  }
}

locals {
  load_balancer_output = local.network_output.in_use == true ? {
    arn      = aws_lb.load_balancer[0].arn
    dns_name = aws_lb.load_balancer[0].dns_name
    zone_id  = aws_lb.load_balancer[0].zone_id
  } : local.null_load_balancer_output
}
