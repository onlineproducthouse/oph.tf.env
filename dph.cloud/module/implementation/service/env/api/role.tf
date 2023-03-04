#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_iam_policy" "launch_config_role_policy" {
  name        = "${var.compute.launch_configuration.name}-role-policy"
  path        = "/system/"
  description = "${var.client_info.project_name} policy for launch configuration"

  policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
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

resource "aws_iam_role" "launch_config_role" {
  name = "${var.compute.launch_configuration.name}-role"
  path = "/system/"

  force_detach_policies = true
  managed_policy_arns   = [aws_iam_policy.launch_config_role_policy.arn]
  permissions_boundary  = ""

  assume_role_policy = jsonencode({
    Version : "2012-10-17",
    Statement : [
      {
        Action : "sts:AssumeRole",
        Principal : {
          Service : "ec2.amazonaws.com"
        },
        Effect : "Allow",
        Sid : ""
      }
    ]
  })

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

resource "aws_iam_instance_profile" "ecs_instance_role" {
  name = "ecsInstanceRole"
  path = "/system/"
  role = aws_iam_role.launch_config_role.name
}

resource "aws_iam_role_policy_attachment" "container_service_attach" {
  role       = aws_iam_role.launch_config_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "ecs_instance_role" {
  value = {
    id = aws_iam_instance_profile.ecs_instance_role.id
  }
}
