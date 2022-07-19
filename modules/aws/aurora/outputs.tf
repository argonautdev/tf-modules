output "cluster_id" {
  description = "The RDS Cluster Identifier"
  value       = module.aurora.cluster_id
}

output "cluster_endpoint" {
  description = "Writer endpoint for the cluster"
  value       = module.aurora.cluster_endpoint
}

output "cluster_reader_endpoint" {
  description = "A read-only endpoint for the cluster, automatically load-balanced across replicas"
  value       = module.aurora.cluster_reader_endpoint
}

output "cluster_port" {
  description = "The database port"
  value       = module.aurora.cluster_port
}

output "cluster_master_password" {
  description = "The database master password"
  value       = module.aurora.cluster_master_password
  sensitive   = true
}

#####################################################
# Error: Output refers to sensitive values
# 
#   on outputs.tf line 27:
#   27: output "cluster_master_username" {
# 
# To reduce the risk of accidentally exporting sensitive data that was intended to be only internal, Terraform requires that any root module output containing sensitive data be
# explicitly marked as sensitive, to confirm your intent.
# 
# If you do intend to export this data, annotate the output value as sensitive by adding the following argument:
#     sensitive = true
#########################################################

output "cluster_master_username" {
  description = "The database master username"
  value       = module.aurora.cluster_master_username
  sensitive   = true
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value = module.aurora.security_group_id
}
