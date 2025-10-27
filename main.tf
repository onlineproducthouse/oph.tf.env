terraform {
  required_version = ">= 1.13.4"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.17.0"
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

  vpc_cidr_block = each.value.vpc_cidr_block

  subnet_cidr_block_private = each.value.subnet_cidr_block_private
  subnet_cidr_block_public  = each.value.subnet_cidr_block_public

  alb_sg_rule = each.value.alb_sg_rule

  sb_eip         = each.value.sb_eip
  sb_nat_gateway = each.value.sb_nat_gateway
  sb_alb         = each.value.sb_alb
}

module "platform" {
  source = "./modules/platform"

  for_each = {
    for i, v in var.platform : v.name => v
  }

  name = each.value.name

  vpc_id    = module.network[each.value.network_name].vpc_id
  subnet_id = module.network[each.value.network_name].subnet_private_id

  cw_log_retention_days = each.value.cw_log_retention_days

  ec2_image_id      = each.value.ec2_image_id
  ec2_instance_type = each.value.ec2_instance_type

  asg_min     = each.value.asg_min
  asg_max     = each.value.asg_max
  asg_desired = each.value.asg_desired

  cluster_sg_rule     = each.value.cluster_sg_rule
  fs_cors_config_rule = each.value.fs_cors_config_rule
}

module "project" {
  source = "./modules/project"

  api = [
    for i, v in var.project.api : {
      name                        = v.name
      region                      = v.region
      hosted_zone_id              = v.hosted_zone_id
      port                        = v.port
      domain_name                 = v.domain_name
      task_network_mode           = v.task_network_mode
      task_launch_type            = v.task_launch_type
      task_cpu                    = v.task_cpu
      task_memory                 = v.task_memory
      task_image                  = v.task_image
      ecs_svc_desired_tasks_count = v.ecs_svc_desired_tasks_count
      ecs_svc_min_health_perc     = v.ecs_svc_min_health_perc
      ecs_svc_max_health_perc     = v.ecs_svc_max_health_perc
      alb_health_check_path       = v.alb_health_check_path

      vpc_id             = module.network[v.network_name].vpc_id
      alb_arn            = module.network[v.network_name].alb_arn
      alb_hosted_zone_id = module.network[v.network_name].alb_hosted_zone_id
      alb_dns_name       = module.network[v.network_name].alb_dns_name

      asg_name         = module.platform[v.platform_name].asg_name
      cluster_id       = module.platform[v.platform_name].cluster_id
      cluster_role_arn = module.platform[v.platform_name].cluster_role_arn
      cw_log_group     = module.platform[v.platform_name].cw_log_group
    }
  ]

  batch = [
    for i, v in var.project.batch : {
      name                        = v.name
      region                      = v.region
      task_network_mode           = v.task_network_mode
      task_launch_type            = v.task_launch_type
      task_cpu                    = v.task_cpu
      task_memory                 = v.task_memory
      task_image                  = v.task_image
      ecs_svc_desired_tasks_count = v.ecs_svc_desired_tasks_count
      ecs_svc_min_health_perc     = v.ecs_svc_min_health_perc
      ecs_svc_max_health_perc     = v.ecs_svc_max_health_perc

      asg_name         = module.platform[v.platform_name].asg_name
      cluster_id       = module.platform[v.platform_name].cluster_id
      cluster_role_arn = module.platform[v.platform_name].cluster_role_arn
      cw_log_group     = module.platform[v.platform_name].cw_log_group
    }
  ]

  www = [
    for i, v in var.project.www : {
      hosted_zone_id = v.hosted_zone_id
      domain_name    = v.domain_name
      index_page     = v.index_page
      error_page     = v.error_page
    }
  ]
}
