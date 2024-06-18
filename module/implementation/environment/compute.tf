#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  cluster_name   = "${local.shared_name}-cluster"
  container_name = "${local.shared_name}-container"
}

resource "aws_security_group" "compute" {
  count = length(aws_vpc.environment) > 0 ? 1 : 0

  name   = "${local.shared_name}-compute-sg"
  vpc_id = aws_vpc.environment[0].id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "compute" {
  for_each = length(aws_security_group.compute) > 0 ? {
    for index, rule in var.environment.compute.security_group_rules : rule.name => rule
  } : {}

  security_group_id = aws_security_group.compute[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}

module "cluster" {
  source = "../../../module/interface/aws/containers/ecs/cluster"

  cluster = {
    name                      = local.cluster_name
    enable_container_insights = local.network_output.in_use == true ? var.environment.compute.enable_container_insights : false
  }
}

resource "aws_launch_template" "compute" {
  count = length(aws_vpc.environment) > 0 ? 1 : 0

  image_id               = var.environment.compute.instance.image_id
  instance_type          = var.environment.compute.instance.instance_type
  name_prefix            = "${local.shared_name}-lt"
  vpc_security_group_ids = [aws_security_group.compute[0].id]

  user_data = base64encode(templatefile("${path.module}/content/user_data.sh", {
    ecs_cluster_name   = local.cluster_name
    ecs_log_driver     = "[\"${local.logging.driver}\"]"
    logs_group         = local.logging.group
    logs_stream_prefix = local.logging.prefix
  }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.environment.arn
  }
}

resource "aws_autoscaling_group" "compute" {
  count = length(aws_vpc.environment) > 0 ? 1 : 0

  name                      = "${local.shared_name}-asg"
  vpc_zone_identifier       = module.private_subnet[0].id_list
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = var.environment.compute.auto_scaling.minimum
  max_size                  = var.environment.compute.auto_scaling.maximum
  desired_capacity          = var.environment.compute.auto_scaling.desired

  launch_template {
    id      = aws_launch_template.compute[0].id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_ecs_capacity_provider" "compute" {
  count = length(aws_vpc.environment) > 0 ? 1 : 0

  name = aws_autoscaling_group.compute[0].name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.compute[0].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.environment.compute.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "compute" {
  count = length(aws_ecs_capacity_provider.compute) > 0 ? 1 : 0

  cluster_name = module.cluster.name

  capacity_providers = [aws_autoscaling_group.compute[0].name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_autoscaling_group.compute[0].name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  compute_output = {
    cluster_id    = module.cluster.id
    cluster_name  = local.cluster_name
    task_role_arn = aws_iam_role.environment.arn

    auto_scaling_group = local.network_output.in_use == true ? aws_autoscaling_group.compute[0] : null

    security_group = local.network_output.in_use == true ? {
      id    = aws_security_group.compute[0].id
      rules = aws_security_group_rule.compute
      } : {
      id    = ""
      rules = {}
    }
  }
}
