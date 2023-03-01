#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "client_info" {
  type = object({
    region             = string
    owner              = string
    project_name       = string
    project_short_name = string
    service_name       = string
    environment_name   = string
  })

  default = {
    region             = ""
    owner              = ""
    project_name       = ""
    project_short_name = ""
    service_name       = ""
    environment_name   = ""
  }
}

variable "cluster" {
  type = object({
    name                      = string
    enable_container_insights = bool
  })

  default = {
    enable_container_insights = false
    name                      = "UnknownECSCluster"
  }
}

#####################################################
#                                                   #
#                   CONFIGURATION                   #
#                                                   #
#####################################################

resource "aws_ecs_cluster" "cluster" {
  name = var.cluster.name

  setting {
    name  = "containerInsights"
    value = var.cluster.enable_container_insights == true ? "enabled" : "disabled"
  }

  tags = {
    owner            = var.client_info.owner
    environment_name = var.client_info.environment_name
    project_name     = var.client_info.project_name
    service_name     = var.client_info.service_name
  }
}

#####################################################
#                                                   #
#                       OUTPUT                      #
#                                                   #
#####################################################

output "name" {
  value = var.cluster.name
}

output "id" {
  value = aws_ecs_cluster.cluster.id
}

output "arn" {
  value = aws_ecs_cluster.cluster.arn
}
