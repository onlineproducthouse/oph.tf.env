output "port" {
  value = var.port
}

output "service_name" {
  value = length(aws_ecs_service.service) > 0 ? aws_ecs_service.service[0].name : ""
}

output "task_family" {
  value = var.name
}

output "cpu" {
  value = var.task_cpu
}

output "memory" {
  value = var.task_memory
}
