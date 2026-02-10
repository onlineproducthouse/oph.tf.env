output "asg_name" {
  value = length(aws_autoscaling_group.asg) > 0 ? aws_autoscaling_group.asg[0].name : ""
}

output "cluster_id" {
  value = aws_ecs_cluster.cluster.id
}

output "cluster_name" {
  value = aws_ecs_cluster.cluster.name
}

output "cluster_role_arn" {
  value = aws_iam_role.role.arn
}

output "fs_s3_bucket_name" {
  value = length(aws_s3_bucket.bucket) > 0 ? aws_s3_bucket.bucket[0].id : ""
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.lg.name
}

output "log_stream_prefix" {
  value = var.log_stream_prefix
}
