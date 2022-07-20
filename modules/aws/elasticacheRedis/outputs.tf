output "cluster_id" {
  value       = module.redis.id
  description = "Redis cluster ID"
}

output "cluster_endpoint" {
  value       = module.redis.endpoint
  description = "Redis primary endpoint"
}

output "cluster_host" {
  value       = module.redis.host
  description = "Redis hostname"
}

// output "cluster_security_group_id" {
//   value       = module.redis.security_group_id
//   description = "Redis Security Group ID"
// }

// output "cluster_security_group_arn" {
//   value       = module.redis.security_group_arn
//   description = "Redis Security Group ARN"
// }

// output "cluster_security_group_name" {
//   value       = module.redis.security_group_name
//   description = "Redis Security Group name"
// }