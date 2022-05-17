output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora_cluster.cluster_id
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora_cluster.cluster_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = module.aurora_cluster.cluster_port
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.aurora_cluster.cluster_master_password
  sensitive   = true
}

output "cluster_master_username" {
  description = "The database master username"
  value       = module.aurora_cluster.cluster_master_username
  sensitive   = true
}