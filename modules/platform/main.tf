resource "aws_cloudwatch_log_group" "lg" {
  count             = local.switchboard.cw ? 1 : 0
  name              = var.name
  retention_in_days = var.cw_log_retention_days
}

#region IAM

resource "aws_iam_policy" "policy" {
  count       = local.switchboard.iam ? 1 : 0
  name        = var.name
  path        = "/system/"
  description = "${var.name} policy for launch template"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid = "Stmt1664390969881",
        Action = [
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:CreateListener",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateRule",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteListener",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:DeleteRule",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:DeregisterTargets",
          "elasticloadbalancing:Describe*",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:ModifyRule",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:RegisterTargets",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:SetIpAddressType",
          "elasticloadbalancing:SetRulePriorities",
          "elasticloadbalancing:SetSecurityGroups",
          "elasticloadbalancing:SetSubnets",
          "elasticloadbalancing:SetWebAcl"
        ],
        Effect   = "Allow",
        Resource = "*"
      },
      {
        Effect : "Allow",
        Action : [
          "s3:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ecr:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ec2:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ecs:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "iam:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ssm:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "autoscaling:CreateOrUpdateTags"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "ses:*"
        ],
        Resource : "*"
      },
      {
        Effect : "Allow",
        Action : [
          "logs:*"
        ],
        Resource : "*"
      }
    ]
  })
}

resource "aws_iam_role" "role" {
  count                = length(aws_iam_policy.policy)
  name                 = var.name
  path                 = "/system/"
  permissions_boundary = ""

  force_detach_policies = true

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Sid : "OPHEC2AssumedRole",
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "ec2.amazonaws.com"
        }
      },
      {
        Sid : "OPHECSTASKAssumedRole",
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "ecs-tasks.amazonaws.com"
        }
      },
      {
        Sid : "OPHECSAssumedRole",
        Action : "sts:AssumeRole",
        Effect : "Allow",
        Principal : {
          Service : "ecs.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_instance_profile" "profile" {
  count = length(aws_iam_policy.policy)
  name  = "${var.name}-ecs"
  path  = "/system/"
  role  = aws_iam_role.role[count.index].name
}

resource "aws_iam_role_policy_attachment" "policy_att" {
  count      = length(aws_iam_policy.policy)
  role       = aws_iam_role.role[count.index].name
  policy_arn = aws_iam_policy.policy[count.index].arn
}

resource "aws_iam_role_policy_attachment" "ec2_policy_att" {
  count      = length(aws_iam_policy.policy)
  role       = aws_iam_role.role[count.index].name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#endregion

#region Storage

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.name}-fs"
}

resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_config" {
  bucket = aws_s3_bucket.bucket.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "cors_config" {
  for_each = {
    for i, v in var.fs_cors_config_rule : i => v
  }

  bucket = aws_s3_bucket.bucket.id
  cors_rule {
    allowed_headers = each.value.allowed_headers
    allowed_methods = each.value.allowed_methods
    allowed_origins = each.value.allowed_origins
    expose_headers  = each.value.expose_headers
    max_age_seconds = each.value.max_age_seconds
  }
}

#endregion

#region Compute

resource "aws_ecs_cluster" "cluster" {
  count = local.switchboard.compute ? 1 : 0
  name  = var.name
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_security_group" "sg" {
  count  = length(aws_ecs_cluster.cluster)
  name   = "${aws_ecs_cluster.cluster[count.index].name}-cluster"
  vpc_id = var.vpc_id

  lifecycle {
    create_before_destroy = false
  }
}

resource "aws_security_group_rule" "sg_rule" {
  for_each = {
    for index, rule in var.cluster_sg_rule : rule.name => rule
  }

  security_group_id = local.switchboard.compute ? aws_security_group.sg[0].id : ""

  type        = each.value.type
  protocol    = each.value.protocol
  cidr_blocks = each.value.cidr_blocks
  from_port   = each.value.from_port
  to_port     = each.value.to_port
}

resource "aws_launch_template" "lt" {
  count       = length(aws_ecs_cluster.cluster)
  name_prefix = var.name

  image_id      = var.ec2_image_id
  instance_type = var.ec2_instance_type

  vpc_security_group_ids = [aws_security_group.sg[count.index].id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.profile[count.index].arn
  }

  user_data = base64encode(templatefile("${path.module}/content/user_data.sh", {
    ecs_cluster_name   = aws_ecs_cluster.cluster[count.index].name
    ecs_log_driver     = "[\"awslogs\"]"
    logs_group         = aws_cloudwatch_log_group.lg[count.index].name
    logs_stream_prefix = "ecs"
  }))
}

resource "aws_autoscaling_group" "asg" {
  count = length(aws_ecs_cluster.cluster)

  name = var.name

  vpc_zone_identifier       = var.subnet_id
  health_check_type         = "ELB"
  health_check_grace_period = 300
  min_size                  = var.asg_min
  max_size                  = var.asg_max
  desired_capacity          = var.asg_desired

  launch_template {
    id      = aws_launch_template.lt[count.index].id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = false
    ignore_changes        = [tag]
  }
}

resource "aws_ecs_capacity_provider" "ecs_cap_provider" {
  count = length(aws_autoscaling_group.asg)

  name = aws_autoscaling_group.asg[count.index].name

  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg[count.index].arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      maximum_scaling_step_size = 1
      minimum_scaling_step_size = 1
      status                    = "ENABLED"
      target_capacity           = 100
    }
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_cap_provider" {
  count = length(aws_autoscaling_group.asg)

  cluster_name       = aws_ecs_cluster.cluster[count.index].name
  capacity_providers = [aws_autoscaling_group.asg[count.index].name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_autoscaling_group.asg[count.index].name
  }
}

#endregion
