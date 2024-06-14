#####################################################
#                                                   #
#                     VARIABLES                     #
#                                                   #
#####################################################

variable "cluster" {
  type = object({
    name                      = string
    enable_container_insights = bool
  })

  default = {
    name                      = "UnknownECSCluster"
    enable_container_insights = false
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
