#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  cluster_name = "${var.platform.name}-cluster"
}

resource "aws_security_group" "compute" {
  count = var.platform.run == true ? 1 : 0

  name   = "${var.platform.name}-compute-sg"
  vpc_id = var.platform.cloud.vpc_id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "compute" {
  for_each = var.platform.run == true && length(aws_security_group.compute) > 0 ? {
    for index, rule in var.platform.compute.security_group_rules : rule.name => rule
  } : {}

  security_group_id = aws_security_group.compute[0].id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}

module "cluster" {
  source = "../../interface/aws/containers/ecs/cluster"

  cluster = {
    name                      = local.cluster_name
    enable_container_insights = var.platform.run == true ? var.platform.compute.enable_container_insights : false
  }
}

resource "aws_launch_template" "compute" {
  count = var.platform.run == true && length(aws_security_group.compute) > 0 ? 1 : 0

  image_id               = var.platform.compute.instance.image_id
  instance_type          = var.platform.compute.instance.instance_type
  name_prefix            = "${var.platform.name}-lt"
  vpc_security_group_ids = [aws_security_group.compute[0].id]

  user_data = base64encode(templatefile("${path.module}/content/user_data.sh", {
    ecs_cluster_name   = local.cluster_name
    ecs_log_driver     = "[\"${local.logging.driver}\"]"
    logs_group         = local.logging.group
    logs_stream_prefix = local.logging.prefix
  }))

  iam_instance_profile {
    arn = aws_iam_instance_profile.platform.arn
  }
}

resource "aws_autoscaling_group" "compute" {
  count = var.platform.run == true && length(aws_launch_template.compute) > 0 ? 1 : 0

  name                      = "${var.platform.name}-asg"
  vpc_zone_identifier       = var.platform.cloud.private_subnet_id_list
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = var.platform.compute.auto_scaling.minimum
  max_size                  = var.platform.compute.auto_scaling.maximum
  desired_capacity          = var.platform.compute.auto_scaling.desired

  launch_template {
    id      = aws_launch_template.compute[0].id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_ecs_capacity_provider" "compute" {
  count = var.platform.run == true && length(aws_autoscaling_group.compute) > 0 ? 1 : 0

  name = aws_autoscaling_group.compute[0].name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.compute[0].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 2
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = var.platform.compute.target_capacity
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "compute" {
  count = var.platform.run == true && length(aws_ecs_capacity_provider.compute) > 0 ? 1 : 0

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
    task_role_arn = aws_iam_role.platform.arn

    auto_scaling_group = var.platform.run == true ? {
      name = length(aws_autoscaling_group.compute) > 0 ? aws_autoscaling_group.compute[0].name : ""
      id   = length(aws_autoscaling_group.compute) > 0 ? aws_autoscaling_group.compute[0].id : ""
      arn  = length(aws_autoscaling_group.compute) > 0 ? aws_autoscaling_group.compute[0].arn : ""
      } : {
      name = ""
      id   = ""
      arn  = ""
    }

    security_group = var.platform.run == true ? {
      id = length(aws_autoscaling_group.compute) > 0 ? aws_autoscaling_group.compute[0].id : ""
      # rules = aws_security_group_rule.compute
      } : {
      id = ""
      # rules = {}
    }
  }
}
