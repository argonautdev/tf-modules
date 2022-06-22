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
  sensitive   = true
  value       = module.aurora_cluster.cluster_master_username
}

output "security_group_id" {
  description = "The security group ID of the cluster"
  value = module.aurora_cluster.security_group_id
}