resource "aws_cloudwatch_log_group" "lg" {
  name              = var.log_group_name
  retention_in_days = var.log_retention_days
}

#region IAM

resource "aws_iam_policy" "policy" {
  name        = var.name
  path        = "/system/"
  description = "${var.name} policy for launch template"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Effect   = "Allow",
        Resource = "*",
        Action   = "*",
        # Action = [
        #   "elasticloadbalancing:AddListenerCertificates",
        #   "elasticloadbalancing:AddTags",
        #   "elasticloadbalancing:CreateListener",
        #   "elasticloadbalancing:CreateLoadBalancer",
        #   "elasticloadbalancing:CreateRule",
        #   "elasticloadbalancing:CreateTargetGroup",
        #   "elasticloadbalancing:DeleteListener",
        #   "elasticloadbalancing:DeleteLoadBalancer",
        #   "elasticloadbalancing:DeleteRule",
        #   "elasticloadbalancing:DeleteTargetGroup",
        #   "elasticloadbalancing:DeregisterTargets",
        #   "elasticloadbalancing:Describe*",
        #   "elasticloadbalancing:ModifyListener",
        #   "elasticloadbalancing:ModifyLoadBalancerAttributes",
        #   "elasticloadbalancing:ModifyRule",
        #   "elasticloadbalancing:ModifyTargetGroup",
        #   "elasticloadbalancing:ModifyTargetGroupAttributes",
        #   "elasticloadbalancing:RegisterTargets",
        #   "elasticloadbalancing:RemoveListenerCertificates",
        #   "elasticloadbalancing:RemoveTags",
        #   "elasticloadbalancing:SetIpAddressType",
        #   "elasticloadbalancing:SetRulePriorities",
        #   "elasticloadbalancing:SetSecurityGroups",
        #   "elasticloadbalancing:SetSubnets",
        #   "elasticloadbalancing:SetWebAcl",

        #   "s3:DeleteObject",
        #   "s3:DeleteObjectTagging",
        #   "s3:DeleteObjectVersion",
        #   "s3:Describe*",
        #   "s3:GetObject",
        #   "s3:GetObjectAttributes",
        #   "s3:GetObjectTagging",
        #   "s3:GetObjectVersion",
        #   "s3:GetObjectVersionAttributes",
        #   "s3:GetObjectVersionTagging",
        #   "s3:ListAllMyBuckets",
        #   "s3:ListBucket",
        #   "s3:ListBucketVersions",
        #   "s3:ListTagsForResource",
        #   "s3:PutObject",
        #   "s3:PutObjectTagging",
        #   "s3:PutObjectVersionTagging",
        #   "s3:TagResource",
        #   "s3:UntagResource",

        #   "ecr:BatchGetImage",
        #   "ecr:Describe*",
        #   "ecr:Get*",
        #   "ecr:List*",

        #   "ec2:AssociateAddress",
        #   "ec2:AssociateIamInstanceProfile",
        #   "ec2:AssociateNatGatewayAddress",
        #   "ec2:AttachNetworkInterface",
        #   "ec2:AuthorizeSecurityGroupEgress",
        #   "ec2:AuthorizeSecurityGroupIngress",
        #   "ec2:CreateCapacityReservation",
        #   "ec2:Describe*",
        #   "ec2:DetachNetworkInterface",
        #   "ec2:DisassociateAddress",
        #   "ec2:DisassociateIamInstanceProfile",
        #   "ec2:DisassociateNatGatewayAddress",
        #   "ec2:Get*",
        #   "ec2:List*",
        #   "ec2:ReleaseAddress",
        #   "ec2:RevokeSecurityGroupEgress",
        #   "ec2:RevokeSecurityGroupIngress",

        #   "ecs:DeregisterContainerInstance",
        #   "ecs:DeregisterTaskDefinition",
        #   "ecs:Describe*",
        #   "ecs:List*",
        #   "ecs:PutClusterCapacityProviders",
        #   "ecs:RegisterContainerInstance",
        #   "ecs:RegisterTaskDefinition",
        #   "ecs:RunTask",
        #   "ecs:StartTask",
        #   "ecs:StopTask",
        #   "ecs:TagResource",
        #   "ecs:UntagResource",

        #   "iam:AddRoleToInstanceProfile",
        #   "iam:AttachRolePolicy",
        #   "iam:DetachRolePolicy",
        #   "iam:Get*",
        #   "iam:List*",
        #   "iam:PassRole",
        #   "iam:TagInstanceProfile",
        #   "iam:TagPolicy",
        #   "iam:TagRole",
        #   "iam:Untag*",

        #   "ssm:Describe*",
        #   "ssm:Get*",
        #   "ssm:List*",

        #   "autoscaling:CreateOrUpdateTags",
        #   "autoscaling:Describe*",

        #   "logs:CreateDelivery",
        #   "logs:CreateLogDelivery",
        #   "logs:CreateLogGroup",
        #   "logs:CreateLogStream",
        #   "logs:Describe*",
        #   "logs:Get*",
        #   "logs:List*",
        #   "logs:Tag*",
        #   "logs:Untag*",
        #   "logs:Put*",
        # ],
      }
    ]
  })
}

resource "aws_iam_role" "role" {
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
  name = "${var.name}-ecs"
  path = "/system/"
  role = aws_iam_role.role.name
}

resource "aws_iam_role_policy_attachment" "policy_att" {
  role       = aws_iam_role.role.name
  policy_arn = aws_iam_policy.policy.arn
}

resource "aws_iam_role_policy_attachment" "ec2_policy_att" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#endregion

#region Storage

resource "aws_s3_bucket" "bucket" {
  count  = local.switchboard.storage ? 1 : 0
  bucket = "${var.name}-fs"
}

resource "aws_s3_bucket_versioning" "versioning" {
  count  = length(aws_s3_bucket.bucket)
  bucket = aws_s3_bucket.bucket[count.index].id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "encrypt_config" {
  count  = length(aws_s3_bucket.bucket)
  bucket = aws_s3_bucket.bucket[count.index].id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_cors_configuration" "cors_config" {
  for_each = {
    for v in var.fs_cors_config_rule : v.id => {
      allowed_headers = v.allowed_headers
      allowed_methods = v.allowed_methods
      allowed_origins = v.allowed_origins
      expose_headers  = v.expose_headers
      max_age_seconds = v.max_age_seconds
    } if length(aws_s3_bucket.bucket) > 0
  }

  bucket = aws_s3_bucket.bucket[0].id

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
  name = var.name
  setting {
    name  = "containerInsights"
    value = "disabled"
  }
}

resource "aws_launch_template" "lt" {
  count       = local.switchboard.compute ? 1 : 0
  name_prefix = var.name

  image_id      = var.ec2_image_id
  instance_type = var.ec2_instance_type

  vpc_security_group_ids = [var.alb_security_group_id]

  iam_instance_profile {
    arn = aws_iam_instance_profile.profile.arn
  }

  user_data = base64encode(templatefile("${path.module}/content/user_data.sh", {
    ecs_cluster_name   = aws_ecs_cluster.cluster.name
    ecs_log_driver     = "[\"awslogs\"]"
    logs_group         = aws_cloudwatch_log_group.lg.name
    logs_stream_prefix = var.log_stream_prefix
  }))
}

resource "aws_autoscaling_group" "asg" {
  count = length(aws_launch_template.lt)

  name = var.name

  vpc_zone_identifier       = var.subnet_id
  health_check_type         = "ELB"
  health_check_grace_period = 500
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

  cluster_name       = aws_ecs_cluster.cluster.name
  capacity_providers = [aws_autoscaling_group.asg[count.index].name]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = aws_autoscaling_group.asg[count.index].name
  }
}

resource "aws_autoscaling_attachment" "api" {
  count = length(aws_autoscaling_group.asg) > 0 ? length(var.alb_target_groups) : 0

  autoscaling_group_name = aws_autoscaling_group.asg[0].name
  lb_target_group_arn    = var.alb_target_groups[count.index]
}

#endregion
