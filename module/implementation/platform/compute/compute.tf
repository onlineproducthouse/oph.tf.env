#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

module "cluster" {
  source = "../../../interface/aws/containers/ecs/cluster"

  cluster = {
    name                      = var.compute.name
    enable_container_insights = false
  }
}

resource "aws_launch_template" "compute" {
  image_id               = var.compute.image_id
  instance_type          = var.compute.instance_type
  name_prefix            = "${var.compute.name}-lt"
  vpc_security_group_ids = [var.compute.security_group_id]

  user_data = base64encode(templatefile("${path.module}/content/user_data.sh", {
    ecs_cluster_name   = var.compute.name
    ecs_log_driver     = "[\"${var.compute.logging.driver}\"]"
    logs_group         = var.compute.logging.group
    logs_stream_prefix = var.compute.logging.prefix
  }))

  iam_instance_profile {
    arn = var.compute.aws_iam_instance_profile_arn
  }
}

resource "aws_autoscaling_group" "compute" {
  count = var.compute.run == true ? 1 : 0

  name                      = "${var.compute.name}-asg"
  vpc_zone_identifier       = var.compute.cloud.private_subnet_id_list
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = var.compute.auto_scaling.minimum
  max_size                  = var.compute.auto_scaling.maximum
  desired_capacity          = var.compute.auto_scaling.desired

  launch_template {
    id      = aws_launch_template.compute.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [tag]
  }
}

resource "aws_ecs_capacity_provider" "compute" {
  count = var.compute.run == true && length(aws_autoscaling_group.compute) > 0 ? 1 : 0

  name = aws_autoscaling_group.compute[0].name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.compute[0].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "compute" {
  count = var.compute.run == true && length(aws_ecs_capacity_provider.compute) > 0 ? 1 : 0

  cluster_name       = module.cluster.name
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
    cluster_name  = module.cluster.name
    task_role_arn = var.compute.task_role_arn

    auto_scaling_group = {
      name = var.compute.run == true ? aws_autoscaling_group.compute[0].name : ""
      id   = var.compute.run == true ? aws_autoscaling_group.compute[0].id : ""
      arn  = var.compute.run == true ? aws_autoscaling_group.compute[0].arn : ""
    }

    security_group = {
      id = var.compute.security_group_id
    }
  }
}
