#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "compute" {
  type = object({
    vpc = object({
      id = string
    })

    auto_scaling_group = object({
      subnet_id_list    = list(string)
      min_instances     = number
      max_instances     = number
      desired_instances = number
    })

    launch_configuration = object({
      name                 = string
      image_id             = string
      instance_type        = string
    })
  })

  default = {
    vpc = {
      id = ""
    }

    auto_scaling_group = {
      desired_instances = 0
      max_instances     = 0
      min_instances     = 0
      subnet_id_list    = []
    }

    launch_configuration = {
      name                 = "UnknownLC"
      image_id             = ""
      instance_type        = ""
    }
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "launch_config_sg" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name   = "${var.compute.launch_configuration.name}-sg"
  vpc_id = var.compute.vpc.id

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
  count = var.compute.vpc.id == "" ? 0 : 1

  security_group_id = aws_security_group.launch_config_sg[0].id
  type              = "egress"
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  from_port         = 0
  to_port           = 0
}

data "template_file" "user_data" {
  template = file("${path.module}/content/user_data.sh")

  vars = {
    ecs_cluster_name = module.cluster.name
    ecs_log_driver   = "[\"syslog\", \"awslogs\"]"
  }
}

resource "aws_launch_configuration" "launch_config" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name                        = var.compute.launch_configuration.name
  associate_public_ip_address = true
  user_data                   = data.template_file.user_data.rendered
  security_groups             = [aws_security_group.launch_config_sg.id]
  image_id                    = var.compute.launch_configuration.image_id
  instance_type               = var.compute.launch_configuration.instance_type
  iam_instance_profile        = ""


  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_autoscaling_group" "auto_scaling_group" {
  count = var.compute.vpc.id == "" ? 0 : 1

  name                 = "${var.compute.launch_configuration.name}-asg"
  health_check_type    = "ELB"
  launch_configuration = aws_launch_configuration.launch_config[0].id
  vpc_zone_identifier  = var.auto_scaling_group.subnet_id_list
  min_size             = var.auto_scaling_group.min_instances
  max_size             = var.auto_scaling_group.max_instances
  desired_capacity     = var.auto_scaling_group.desired_instances

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
  compute = var.compute.vpc.id == "" ? {
    security_group_id      = ""
    security_group_rule_id = ""
    launch_config_id       = ""
    } : {
    security_group_id      = aws_security_group.launch_config_sg.id
    security_group_rule_id = aws_security_group_rule.launch_config_sg_rule.id
    launch_config_id       = aws_launch_configuration.launch_config.id
  }
}

output "compute" {
  value = local.compute
}
