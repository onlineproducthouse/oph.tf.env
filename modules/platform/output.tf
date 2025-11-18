output "asg_name" {
  value = var.asg_desired > 0 ? aws_autoscaling_group.asg[0].name : ""
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cluster_role_arn" {
  value = aws_iam_role.role.arn
}

output "cw_log_group" {
  value = aws_cloudwatch_log_group.lg.name
}

output "fs_s3_bucket_name" {
  value = aws_s3_bucket.bucket.id
}
