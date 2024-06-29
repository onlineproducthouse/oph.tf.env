#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "load_balancer" {
  count = var.cloud.run == true && length(aws_vpc.cloud) > 0 ? 1 : 0

  name   = "${var.cloud.name}-lb-sg"
  vpc_id = aws_vpc.cloud[0].id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "load_balancer" {
  for_each = var.cloud.run == true && length(aws_security_group.load_balancer) > 0 ? {
    for index, rule in var.cloud.load_balancer.security_group_rules : rule.name => rule
  } : {}

  security_group_id = aws_security_group.load_balancer[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_lb" "cloud" {
  count = var.cloud.run == true && length(aws_vpc.cloud) > 0 ? 1 : 0

  name               = "${var.cloud.name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.load_balancer[0].id]
  subnets            = local.network_output.subnet_id_list.public

  access_logs {
    enabled = true
    bucket  = local.storage_output.id
    prefix  = "${var.cloud.name}-lb"
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
  load_balancer_output = var.cloud.run == true ? {
    arn      = aws_lb.cloud[0].arn
    dns_name = aws_lb.cloud[0].dns_name
    zone_id  = aws_lb.cloud[0].zone_id
  } : local.null_load_balancer_output
}
