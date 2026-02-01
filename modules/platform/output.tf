output "asg_name" {
  value = length(aws_autoscaling_group.asg) > 0 ? aws_autoscaling_group.asg[0].name : ""
}

output "cluster_id" {
  value = length(aws_ecs_cluster.cluster) > 0 ? aws_ecs_cluster.cluster[0].id : ""
}

output "cluster_name" {
  value = length(aws_ecs_cluster.cluster) > 0 ? aws_ecs_cluster.cluster[0].name : ""
}

output "cluster_role_arn" {
  value = length(aws_iam_role.role) > 0 ? aws_iam_role.role[0].arn : ""
}

output "cw_log_group" {
  value = length(aws_cloudwatch_log_group.lg) > 0 ? aws_cloudwatch_log_group.lg[0].name : ""
}

output "fs_s3_bucket_name" {
  value = aws_s3_bucket.bucket.id
}
