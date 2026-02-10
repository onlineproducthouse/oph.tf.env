terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.23.0"
    }
  }
}

module "network" {
  source = "./modules/network"

  for_each = {
    for i, v in var.network : v.name => v
  }

  name              = each.value.name
  availability_zone = each.value.availability_zone

  vpc_cidr_block            = each.value.vpc_cidr_block
  subnet_cidr_block_private = each.value.subnet_cidr_block_private
  subnet_cidr_block_public  = each.value.subnet_cidr_block_public

  alb_domain_name_alias         = each.value.alb_domain_name_alias
  alb_domain_name_alias_zone_id = each.value.alb_domain_name_alias_zone_id
  alb_sg_rule                   = each.value.alb_sg_rule
  alb_target_groups             = each.value.alb_target_groups

  sb_eip         = each.value.sb_eip
  sb_nat_gateway = each.value.sb_nat_gateway
  sb_alb         = each.value.sb_alb
}

module "platform" {
  source = "./modules/platform"

  for_each = {
    for i, v in var.platform : v.name => v
  }

  name = each.key

  subnet_id = each.value.network_name == "" ? [] : module.network[each.value.network_name].subnet_private_id

  fs_cors_config_rule = [
    {
      id              = "write"
      allowed_methods = ["PUT", "POST"]
      allowed_origins = each.value.fs_cors_origins
      allowed_headers = ["*"]
      expose_headers  = ["ETag"]
      max_age_seconds = 3000
    },
    {
      id              = "read"
      allowed_methods = ["GET"]
      allowed_origins = ["*"]
      allowed_headers = null
      expose_headers  = null
      max_age_seconds = null
    },
  ]

  ec2_image_id      = each.value.ec2_image_id
  ec2_instance_type = each.value.ec2_instance_type

  asg_min     = each.value.asg_min
  asg_max     = each.value.asg_max
  asg_desired = each.value.asg_desired

  log_group_name     = each.value.log_group_name
  log_stream_prefix  = each.value.log_stream_prefix
  log_retention_days = each.value.log_retention_days

  alb_target_groups     = [for k, v in module.network[each.value.network_name].alb_target_groups : v.arn]
  alb_security_group_id = module.network[each.value.network_name].alb_security_group_id

  sb_compute = each.value.sb_compute
  sb_storage = each.value.sb_storage
}

module "project" {
  source = "./modules/project"

  api = [
    for i, v in var.project.api : {
      name   = v.name
      region = v.region

      port                 = v.port
      domain_name          = v.domain_name
      alb_target_group_arn = module.network[v.network_name].alb_target_groups[v.alb_target_group_id].arn
      asg_name             = module.platform[v.platform_name].asg_name

      cluster_id       = module.platform[v.platform_name].cluster_id
      cluster_role_arn = module.platform[v.platform_name].cluster_role_arn

      task_cpu    = v.task_cpu
      task_memory = v.task_memory
      task_image  = v.task_image

      log_group_name    = module.platform[v.platform_name].log_group_name
      log_stream_prefix = module.platform[v.platform_name].log_stream_prefix

      ecs_svc_desired_tasks_count = v.ecs_svc_desired_tasks_count
      ecs_svc_min_health_perc     = v.ecs_svc_min_health_perc
      ecs_svc_max_health_perc     = v.ecs_svc_max_health_perc
    }
  ]

  batch = [
    for i, v in var.project.batch : {
      name   = v.name
      region = v.region

      asg_name = module.platform[v.platform_name].asg_name

      cluster_id       = module.platform[v.platform_name].cluster_id
      cluster_role_arn = module.platform[v.platform_name].cluster_role_arn

      task_cpu    = v.task_cpu
      task_memory = v.task_memory
      task_image  = v.task_image

      log_group_name    = module.platform[v.platform_name].log_group_name
      log_stream_prefix = module.platform[v.platform_name].log_stream_prefix

      ecs_svc_desired_tasks_count = v.ecs_svc_desired_tasks_count
      ecs_svc_min_health_perc     = v.ecs_svc_min_health_perc
      ecs_svc_max_health_perc     = v.ecs_svc_max_health_perc
    }
  ]

  web = [
    for i, v in var.project.web : {
      name                = v.name
      hosted_zone_id      = v.hosted_zone_id
      acm_certificate_arn = v.acm_certificate_arn
      domain_name         = v.domain_name
      index_page          = v.index_page
      error_page          = v.error_page
    }
  ]
}

resource "aws_ssm_parameter" "parameters" {
  for_each = {
    for i, v in var.config.variables : "${v.key}_${i}" => v
  }

  type      = "SecureString"
  name      = "${each.value.path}/${each.value.key}"
  value     = each.value.value
  overwrite = true
}
