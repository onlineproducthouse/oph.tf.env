#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "compute" {
  type = object({
    auto_scaling_group = object({
      min_instances     = number
      max_instances     = number
      desired_instances = number
    })

    launch_configuration = object({
      name          = string
      image_id      = string
      instance_type = string
    })
  })

  default = {
    auto_scaling_group = {
      desired_instances = 0
      max_instances     = 0
      min_instances     = 0
    }

    launch_configuration = {
      name          = "UnknownLC"
      image_id      = ""
      instance_type = ""
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "launch_config_sg" {
  count = length(aws_vpc.vpc) > 0 ? 1 : 0

  name   = "${var.compute.launch_configuration.name}-sg"
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

resource "aws_security_group_rule" "launch_config_sg_rule" {
  count = length(aws_security_group.launch_config_sg) > 0 ? 1 : 0

  security_group_id = aws_security_group.launch_config_sg[0].id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
}

resource "aws_security_group_rule" "launch_config_sg_ingress_rule" {
  count = length(aws_security_group.launch_config_sg) > 0 ? 1 : 0

  security_group_id = aws_security_group.launch_config_sg[0].id
  type              = "ingress"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # for this environment, investigate using VPN
  from_port         = var.port
  to_port           = var.port
}

data "template_file" "user_data" {
  template = file("${path.module}/content/user_data.sh")

  vars = {
    ecs_cluster_name = module.cluster.name
    ecs_log_driver   = "[\"syslog\", \"awslogs\"]"
  }
}

resource "aws_launch_configuration" "launch_config" {
  count = length(aws_security_group.launch_config_sg) > 0 ? 1 : 0

  name                        = var.compute.launch_configuration.name
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  security_groups             = [aws_security_group.launch_config_sg[0].id]
  image_id                    = var.compute.launch_configuration.image_id
  instance_type               = var.compute.launch_configuration.instance_type
  iam_instance_profile        = aws_iam_instance_profile.ecs_instance_role.id


  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_autoscaling_group" "launch_config_auto_scaling_group" {
  count = length(aws_launch_configuration.launch_config) > 0 ? 1 : 0

  name                 = "${var.compute.launch_configuration.name}-asg"
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.launch_config[0].id
  vpc_zone_identifier  = module.private_subnet[0].id_list
  min_size             = var.compute.auto_scaling_group.min_instances
  max_size             = var.compute.auto_scaling_group.max_instances
  desired_capacity     = var.compute.auto_scaling_group.desired_instances

  lifecycle {
    create_before_destroy = false
  }

  tag {
    key                 = "owner"
    value               = var.client_info.owner
    propagate_at_launch = true
  }

  tag {
    key                 = "environment_name"
    value               = var.client_info.environment_name
    propagate_at_launch = true
  }

  tag {
    key                 = "project_name"
    value               = var.client_info.project_name
    propagate_at_launch = true
  }

  tag {
    key                 = "service_name"
    value               = var.client_info.service_name
    propagate_at_launch = true
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  compute = var.network.vpc_cidr_block == "" ? {
    security_group_id              = ""
    security_group_rule_id         = ""
    security_group_ingress_rule_id = ""
    launch_config_id               = ""
    } : {
    security_group_id              = aws_security_group.launch_config_sg[0].id
    security_group_rule_id         = aws_security_group_rule.launch_config_sg_rule[0].id
    security_group_ingress_rule_id = aws_security_group_rule.launch_config_sg_ingress_rule[0].id
    launch_config_id               = aws_launch_configuration.launch_config[0].id
  }
}

output "compute" {
  value = local.compute
}
