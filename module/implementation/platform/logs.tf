#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

locals {
  cloud_watch_log_group_list = [
    { key = "main", value = local.logging.group },
  ]

  logging = {
    driver = "awslogs"
    prefix = "ecs"
    group  = var.platform.logs.group
  }
}

resource "aws_cloudwatch_log_group" "platform" {
  for_each = {
    for index, group in local.cloud_watch_log_group_list : group.key => group
  }

  name              = each.value.value
  retention_in_days = 7
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

locals {
  logs_output = {
    logging = local.logging
  }
}
