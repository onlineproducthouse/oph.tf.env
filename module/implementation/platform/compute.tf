#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_security_group" "compute" {
  name   = "${var.platform.name}-compute-sg"
  vpc_id = var.platform.cloud.vpc_id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "compute" {
  for_each = {
    for index, rule in var.platform.security_group_rules : rule.name => rule
  }

  security_group_id = aws_security_group.compute.id

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}

module "compute" {
  source = "./compute"

  for_each = {
    for i, v in var.platform.compute : v.name => v
  }

  compute = {
    run = var.platform.run

    name   = each.value.name
    region = var.platform.region

    cloud = {
      private_subnet_id_list = var.platform.cloud.private_subnet_id_list
    }

    image_id      = each.value.image_id
    instance_type = each.value.instance_type
    auto_scaling  = each.value.auto_scaling

    vpc_security_group_ids = [aws_security_group.compute.id]

    aws_iam_instance_profile_arn = local.role_output.instance.arn
    task_role_arn                = local.role_output.arn
    logging                      = local.logs_output.logging
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  compute_output = module.compute
}
