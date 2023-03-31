#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_cloudwatch_log_group" "container" {
  for_each = {
    for index, group in local.cloud_watch_log_group_list : group.key => group
  }

  name              = each.value.value
  retention_in_days = 30

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}
