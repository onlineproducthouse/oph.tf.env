resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id
}

#########################
#                       #
#    Public network     #
#                       #
#########################
resource "aws_subnet" "subnet_public" {
  count = length(var.subnet_cidr_block_public)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  cidr_block        = element(var.subnet_cidr_block_public, count.index)
}

resource "aws_eip" "eip" {
  count  = local.switchboard.eip ? length(var.subnet_cidr_block_public) : 0
  domain = "vpc"
}

resource "aws_nat_gateway" "nat" {
  count = length(aws_eip.eip) > 0 ? length(aws_subnet.subnet_public.*.id) : 0

  allocation_id = element(aws_eip.eip.*.id, count.index)
  subnet_id     = element(aws_subnet.subnet_public.*.id, count.index)
}

resource "aws_route_table" "route_table_public" {
  count  = length(aws_subnet.subnet_public.*.id)
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_assoc_public" {
  count = length(aws_subnet.subnet_public.*.id)

  subnet_id      = element(aws_subnet.subnet_public.*.id, count.index)
  route_table_id = element(aws_route_table.route_table_public.*.id, count.index)
}

resource "aws_route" "route_public" {
  count = length(aws_route_table.route_table_public.*.id)

  route_table_id         = element(aws_route_table.route_table_public.*.id, count.index)
  gateway_id             = aws_internet_gateway.igw.id
  destination_cidr_block = "0.0.0.0/0"
}

#########################
#                       #
#    Private network    #
#                       #
#########################
resource "aws_subnet" "subnet_private" {
  count = length(var.subnet_cidr_block_private)

  vpc_id            = aws_vpc.vpc.id
  availability_zone = element(var.availability_zone, count.index)
  cidr_block        = element(var.subnet_cidr_block_private, count.index)
}

resource "aws_route_table" "route_table_private" {
  count  = length(aws_subnet.subnet_private.*.id)
  vpc_id = aws_vpc.vpc.id
}

resource "aws_route_table_association" "route_table_assoc_private" {
  count = length(aws_subnet.subnet_private.*.id)

  subnet_id      = element(aws_subnet.subnet_private.*.id, count.index)
  route_table_id = element(aws_route_table.route_table_private.*.id, count.index)
}

resource "aws_route" "route_private" {
  count = length(aws_nat_gateway.nat) > 0 ? length(aws_route_table.route_table_private.*.id) : 0

  route_table_id         = element(aws_route_table.route_table_private.*.id, count.index)
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
}

#########################
#                       #
#    Load Balancer      #
#                       #
#########################
resource "aws_security_group" "alb" {
  name   = "${var.name}-alb"
  vpc_id = aws_vpc.vpc.id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "alb" {
  for_each = {
    for i, v in var.alb_sg_rule : v.name => v
  }

  security_group_id = aws_security_group.alb.id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.port
  to_port     = each.value.port
}

resource "aws_lb" "alb" {
  count = local.switchboard.alb ? 1 : 0

  name               = var.name
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = aws_subnet.subnet_public.*.id
}
