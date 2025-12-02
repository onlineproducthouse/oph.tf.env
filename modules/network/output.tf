output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.vpc.id
}

output "subnet_private_id" {
  description = "List of private AWS Subnet IDs"
  value       = aws_subnet.subnet_private.*.id
}

output "subnet_private_cidr_block" {
  description = "List of private AWS Subnet CIDR blocks"
  value       = aws_subnet.subnet_private.*.cidr_block
}

output "subnet_public_cidr_block" {
  description = "List of public AWS Subnet CIDR blocks"
  value       = aws_subnet.subnet_public.*.cidr_block
}

output "alb_available" {
  description = "Indicator whether the consuming module can expect an ALB to have been provisioned"
  value       = local.switchboard.alb
}

output "alb_arn" {
  description = "ARN of the load balancer"
  value       = local.switchboard.alb ? aws_lb.alb[0].arn : ""
}

output "alb_dns_name" {
  description = "DNS name of the load balancer"
  value       = local.switchboard.alb ? aws_lb.alb[0].dns_name : ""
}

output "alb_hosted_zone_id" {
  description = "Canonical hosted zone ID of the load balancer"
  value       = local.switchboard.alb ? aws_lb.alb[0].zone_id : ""
}

# output "eip_id" {
#   description = "List of AWS Elastic IP IDs"
#   value       = aws_eip.eip.*.id
# }

# output "subnet_public_id" {
#   description = "List of public AWS Subnet IDs"
#   value       = aws_subnet.subnet_public.*.id
# }
