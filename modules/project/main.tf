module "api" {
  source = "./api"

  for_each = {
    for i, v in var.api : v.name => v
  }

  name                        = each.value.name
  region                      = each.value.region
  vpc_id                      = each.value.vpc_id
  hosted_zone_id              = each.value.hosted_zone_id
  port                        = each.value.port
  domain_name                 = each.value.domain_name
  alb_available               = each.value.alb_available
  alb_arn                     = each.value.alb_arn
  alb_hosted_zone_id          = each.value.alb_hosted_zone_id
  alb_dns_name                = each.value.alb_dns_name
  alb_health_check_path       = each.value.alb_health_check_path
  asg_name                    = each.value.asg_name
  cluster_id                  = each.value.cluster_id
  cluster_role_arn            = each.value.cluster_role_arn
  task_cpu                    = each.value.task_cpu
  task_memory                 = each.value.task_memory
  task_image                  = each.value.task_image
  cw_log_group                = each.value.cw_log_group
  ecs_svc_desired_tasks_count = each.value.ecs_svc_desired_tasks_count
  ecs_svc_min_health_perc     = each.value.ecs_svc_min_health_perc
  ecs_svc_max_health_perc     = each.value.ecs_svc_max_health_perc
}

module "batch" {
  source = "./batch"

  for_each = {
    for i, v in var.batch : v.name => v
  }

  name                        = each.value.name
  region                      = each.value.region
  asg_name                    = each.value.asg_name
  cluster_id                  = each.value.cluster_id
  cluster_role_arn            = each.value.cluster_role_arn
  task_cpu                    = each.value.task_cpu
  task_memory                 = each.value.task_memory
  task_image                  = each.value.task_image
  cw_log_group                = each.value.cw_log_group
  ecs_svc_desired_tasks_count = each.value.ecs_svc_desired_tasks_count
  ecs_svc_min_health_perc     = each.value.ecs_svc_min_health_perc
  ecs_svc_max_health_perc     = each.value.ecs_svc_max_health_perc
}

module "web" {
  source = "./web"

  for_each = {
    for i, v in var.web : v.name => v
  }

  hosted_zone_id = each.value.hosted_zone_id
  domain_name    = each.value.domain_name
  index_page     = each.value.index_page
  error_page     = each.value.error_page
}
